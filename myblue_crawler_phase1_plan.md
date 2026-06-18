# MyBlue Crawler — Phase 1 Development Plan

> **Scope:** Level 0 (login + landing page) → Level 1 (all links discovered from landing page)  
> **Goal:** Get clean, validated data from Level 1 pages into S3 before expanding to deeper levels.

---

## Project Structure

```
myblue-crawler/
├── crawler/
│   ├── __init__.py
│   ├── auth.py          # Login + session management
│   ├── browser.py       # Selenium / BeautifulSoup4 wrapper
│   ├── discovery.py     # Link extraction + normalization
│   ├── extractor.py     # Content + metadata extraction
│   ├── storage.py       # S3 upload
│   └── config.py        # Config loader
├── config/
│   └── crawler.json     # Runtime parameters
├── tests/
│   ├── test_auth.py
│   ├── test_discovery.py
│   └── test_extractor.py
├── main.py              # Entry point — Level 1 crawl loop
├── requirements.txt
└── README.md
```

---

## Step 1 — Project Setup

### `requirements.txt`

```
boto3
selenium
beautifulsoup4
requests
pydantic
python-dotenv
```

### `config/crawler.json`

```json
{
  "login_url": "https://myblue.fepblue.org/login",
  "max_depth": 1,
  "max_urls_per_persona": 200,
  "request_delay_seconds": 2,
  "request_delay_max_seconds": 5,
  "session_timeout_minutes": 30,
  "retry_attempts": 3,
  "concurrent_personas": 1,
  "bucket_name": "bcbsa-myblue-crawler",
  "region": "us-east-1",
  "skip_patterns": [
    ".css", ".js", ".png", ".jpg", ".svg", ".ico",
    "/logout", "/login", "#"
  ]
}
```

---

## Step 2 — Auth Module (`crawler/auth.py`)

**Responsibility:** Log in, manage the session cookie, re-authenticate on expiry.

### What to build

- `SessionManager` class with:
  - `login()` — loads login page, extracts CSRF token, POSTs credentials, stores session cookie
  - `is_valid()` — checks if 30-minute TTL has elapsed
  - `get_session()` — returns the active session (re-auths if expired)
- Credentials pulled from **AWS Secrets Manager** (not hardcoded)
- Retry logic: 3 attempts with exponential backoff on failure

### Stub

```python
import boto3
import requests
import time
from bs4 import BeautifulSoup

class SessionManager:
    def __init__(self, persona: str, config: dict):
        self.persona = persona
        self.config = config
        self.session = requests.Session()
        self.login_time = None

    def _get_credentials(self) -> dict:
        """Pull credentials from AWS Secrets Manager."""
        client = boto3.client("secretsmanager", region_name=self.config["region"])
        secret = client.get_secret_value(SecretId=f"myblue/{self.persona}")
        # parse and return {"username": ..., "pin": ...}

    def _extract_csrf(self, html: str) -> str:
        """Extract CSRF token from login page HTML."""
        soup = BeautifulSoup(html, "html.parser")
        # locate the CSRF input field — inspect the real login page to find the field name
        token = soup.find("input", {"name": "csrf_token"})
        return token["value"] if token else ""

    def login(self) -> bool:
        """Authenticate and store session cookie."""
        # 1. GET login page
        # 2. Extract CSRF token
        # 3. POST credentials
        # 4. Validate response (check for redirect or success indicator)
        # 5. Store session cookie + login_time
        pass

    def is_valid(self) -> bool:
        if not self.login_time:
            return False
        elapsed = (time.time() - self.login_time) / 60
        return elapsed < self.config["session_timeout_minutes"]

    def get_session(self) -> requests.Session:
        if not self.is_valid():
            self.login()
        return self.session
```

### Validation checkpoint

Run `auth.py` standalone. Print the session cookie and confirm you're hitting an authenticated page (not a login redirect).

---

## Step 3 — Browser Wrapper (`crawler/browser.py`)

**Responsibility:** Fetch pages using the right engine. Inject session cookies. Throttle requests.

### What to build

- `fetch(url, session)` — tries BS4 first (fast), falls back to Selenium if JS content is detected
- Random delay between `request_delay_seconds` and `request_delay_max_seconds`
- Returns a `PageResult` dataclass: `{url, html, status_code, extraction_method}`

### Stub

```python
import time
import random
from dataclasses import dataclass
from bs4 import BeautifulSoup
from selenium import webdriver

@dataclass
class PageResult:
    url: str
    html: str
    status_code: int
    extraction_method: str  # "beautifulsoup" | "selenium"

def fetch(url: str, session, config: dict) -> PageResult:
    delay = random.uniform(
        config["request_delay_seconds"],
        config["request_delay_max_seconds"]
    )
    time.sleep(delay)
    # 1. Try requests + BS4
    # 2. If JS-rendered content detected (empty body, known JS indicators), use Selenium
    # 3. Return PageResult
    pass
```

---

## Step 4 — Link Discovery (`crawler/discovery.py`)

**Responsibility:** Extract all links from a page, normalize them, deduplicate, and filter out noise.

### What to build

- `get_links(html, base_url, skip_patterns)` — returns a clean list of absolute URLs
- URL normalization: resolve relative paths, strip fragments and tracking params
- Skip filter: drop URLs matching any pattern in `skip_patterns`
- Deduplication: maintain a `seen` set across the crawl session

### Stub

```python
from urllib.parse import urljoin, urlparse, urlunparse
from bs4 import BeautifulSoup

def normalize_url(url: str, base_url: str) -> str:
    """Resolve relative URLs and strip fragments."""
    absolute = urljoin(base_url, url)
    parsed = urlparse(absolute)
    # strip fragment
    clean = parsed._replace(fragment="")
    return urlunparse(clean)

def get_links(html: str, base_url: str, skip_patterns: list, seen: set) -> list[str]:
    soup = BeautifulSoup(html, "html.parser")
    links = []
    for tag in soup.find_all("a", href=True):
        url = normalize_url(tag["href"], base_url)
        if url in seen:
            continue
        if any(p in url for p in skip_patterns):
            continue
        seen.add(url)
        links.append(url)
    return links
```

### Validation checkpoint

Run discovery on the landing page after auth. Print all discovered URLs. This list is your Level 1 queue.

---

## Step 5 — Content Extractor (`crawler/extractor.py`)

**Responsibility:** Extract cleaned content and structured metadata from each Level 1 page.

### Metadata schema (from spec §8.1)

```python
from pydantic import BaseModel
from typing import Literal
import hashlib, time

class PageMetadata(BaseModel):
    document_id: str
    url: str
    title: str
    persona_type: Literal["individual", "family", "medicare", "group"]
    content_category: Literal["benefits", "claims", "providers", "prescriptions", "unknown"]
    crawl_timestamp: str   # ISO 8601
    session_id: str
    content_hash: str
    page_size: int
    extraction_method: Literal["beautifulsoup", "selenium"]
```

### Content category detection (from spec §4.3)

```python
CATEGORY_KEYWORDS = {
    "benefits":      ["plan", "coverage", "benefit"],
    "claims":        ["claim", "reimbursement", "eob"],
    "providers":     ["doctor", "network", "directory"],
    "prescriptions": ["pharmacy", "drug", "medication"],
}

def detect_category(text: str) -> str:
    text_lower = text.lower()
    for category, keywords in CATEGORY_KEYWORDS.items():
        if any(kw in text_lower for kw in keywords):
            return category
    return "unknown"
```

### Content cleaning

```python
from bs4 import BeautifulSoup

def clean_html(html: str) -> str:
    """Remove scripts, styles, and nav elements. Return plain text."""
    soup = BeautifulSoup(html, "html.parser")
    for tag in soup(["script", "style", "nav", "header", "footer"]):
        tag.decompose()
    return soup.get_text(separator=" ", strip=True)
```

---

## Step 6 — S3 Storage (`crawler/storage.py`)

**Responsibility:** Upload HTML and metadata files to the correct S3 paths.

### S3 path structure (from spec §7.1)

```
bcbsa-myblue-crawler/
└── raw-content/
    └── {persona}/
        └── YYYY-MM-DD/
            ├── html/      {persona}_{timestamp}_{url_hash}.html.gz
            └── metadata/  {persona}_{timestamp}_{url_hash}.json
```

### Stub

```python
import boto3
import gzip
import json
from datetime import date

def upload_page(metadata: dict, html: str, config: dict):
    s3 = boto3.client("s3", region_name=config["region"])
    today = date.today().isoformat()
    persona = metadata["persona_type"]
    file_id = f"{persona}_{metadata['crawl_timestamp']}_{metadata['document_id']}"
    prefix = f"raw-content/{persona}/{today}"

    # Upload compressed HTML
    html_key = f"{prefix}/html/{file_id}.html.gz"
    s3.put_object(
        Bucket=config["bucket_name"],
        Key=html_key,
        Body=gzip.compress(html.encode("utf-8")),
        ContentEncoding="gzip",
        ContentType="text/html",
    )

    # Upload metadata JSON
    meta_key = f"{prefix}/metadata/{file_id}.json"
    s3.put_object(
        Bucket=config["bucket_name"],
        Key=meta_key,
        Body=json.dumps(metadata).encode("utf-8"),
        ContentType="application/json",
    )
```

---

## Step 7 — Main Crawl Loop (`main.py`)

Wire all modules together for a Level 1 run.

```python
import json
import logging
from crawler.auth import SessionManager
from crawler.browser import fetch
from crawler.discovery import get_links
from crawler.extractor import extract_metadata, clean_html
from crawler.storage import upload_page

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")

def run(persona: str):
    with open("config/crawler.json") as f:
        config = json.load(f)

    session_manager = SessionManager(persona, config)
    session_manager.login()
    session = session_manager.get_session()

    # --- Level 0: fetch landing page, discover Level 1 links ---
    landing = fetch(config["login_url"], session, config)
    seen = set()
    level1_urls = get_links(landing.html, config["login_url"], config["skip_patterns"], seen)
    logging.info(f"Discovered {len(level1_urls)} Level 1 URLs")

    # --- Level 1: crawl each discovered URL ---
    for i, url in enumerate(level1_urls[:config["max_urls_per_persona"]]):
        if not session_manager.is_valid():
            logging.info("Session expired — re-authenticating")
            session_manager.login()
            session = session_manager.get_session()

        try:
            page = fetch(url, session, config)
            metadata = extract_metadata(page, persona)
            upload_page(metadata, page.html, config)
            logging.info(f"[{i+1}/{len(level1_urls)}] OK  {url}  category={metadata['content_category']}")
        except Exception as e:
            logging.error(f"[{i+1}/{len(level1_urls)}] FAIL {url} — {e}")

if __name__ == "__main__":
    run(persona="individual")
```

---

## Validation Checklist (before moving to Level 2)

Run a 50-page sample against the portal and confirm all of the following:

- [ ] Persona logs in successfully and session cookie is present
- [ ] Re-auth triggers correctly after 30 minutes
- [ ] All Level 1 URLs discovered and deduplicated (no duplicates in queue)
- [ ] Skip patterns are filtering out `.css`, `.js`, images, and login redirects
- [ ] Metadata JSON matches spec schema (all required fields present)
- [ ] `content_category` is populated for at least 80% of pages
- [ ] HTML and metadata files appear in the correct S3 paths
- [ ] Error rate is under 5% across the sample run
- [ ] Logs show status code, category, and S3 path for every URL

---

## What Level 2 Adds (for reference)

Once Level 1 is validated, Level 2 is straightforward:

1. After extracting each Level 1 page, run `get_links()` on it to collect Level 2 URLs
2. Add those to a secondary queue (respecting `max_depth: 3` and `max_urls_per_persona: 200`)
3. Feed Level 2 URLs through the same `fetch → extract → upload` loop
4. The extractor and storage modules need **no changes** — only the crawl loop in `main.py` grows

---

## Key Spec References

| Topic | Spec Section |
|---|---|
| Auth flow | §6.1 |
| Session lifecycle | §6.2 |
| Rate limiting | §6.3 |
| Content categories | §4.3 |
| Metadata schema | §8.1 |
| S3 bucket structure | §7.1 |
| Crawl parameters | §5.1 |
| Skip patterns | §5.2 |
| Error handling | §5.3 |
