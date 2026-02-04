# Deploy to GitHub Pages 🚀

GitHub Pages is FREE and easier than AWS! Your site will be at:
`https://YOUR-USERNAME.github.io/valentine-pc/`

## Quick Setup (5 minutes)

### Step 1: Create a GitHub Repository

1. Go to https://github.com/new
2. Repository name: `valentine-pc` (this will be in your URL!)
3. Make it **Public**
4. Don't initialize with README
5. Click "Create repository"

### Step 2: Deploy Your Files

Open Command Prompt in your project folder and run:

```bash
# Initialize git repository
git init

# Add all files
git add valentine.html style.css script.js

# Create first commit
git commit -m "Initial commit - Valentine's Day project"

# Rename branch to main
git branch -M main

# Add your GitHub repository (REPLACE YOUR-USERNAME!)
git remote add origin https://github.com/YOUR-USERNAME/valentine-pc.git

# Push to GitHub
git push -u origin main
```

### Step 3: Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **Settings** tab
3. Click **Pages** in the left sidebar
4. Under "Source":
   - Branch: Select `main`
   - Folder: Select `/ (root)`
5. Click **Save**

### Step 4: Access Your Site!

Your site will be live at:
```
https://YOUR-USERNAME.github.io/valentine-pc/valentine.html
```

Or you can rename `valentine.html` to `index.html` to access it at:
```
https://YOUR-USERNAME.github.io/valentine-pc/
```

---

## Make it index.html (Optional but Recommended)

To access your site without `/valentine.html` at the end:

```bash
# Rename the file
ren valentine.html index.html

# Commit the change
git add .
git commit -m "Rename to index.html"
git push
```

Then update the HTML file references if needed.

---

## Benefits of GitHub Pages

✅ **Completely FREE** (no credit card needed)
✅ **No AWS configuration** needed
✅ **Automatic HTTPS** (secure by default)
✅ **Fast CDN** (globally distributed)
✅ **Easy updates** (just git push)
✅ **Custom domains** supported (free!)

---

## Updating Your Site

After making changes to your files:

```bash
git add .
git commit -m "Updated design"
git push
```

Changes appear live in 1-2 minutes!

---

## Troubleshooting

### "git is not recognized"
- Install Git: https://git-scm.com/download/win
- Restart Command Prompt

### 404 Error
- Wait 2-3 minutes after enabling Pages
- Check you're using the correct URL
- Ensure `index.html` or `valentine.html` exists

### Permission denied
- Set up GitHub authentication: https://docs.github.com/en/authentication

---

## Need a Custom Domain?

You can use your own domain (like `valentine-pc.com`) for FREE with GitHub Pages!

Just add a CNAME file with your domain name.

---

Happy Valentine's Day! 💝
