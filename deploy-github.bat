@echo off
echo ====================================
echo GitHub Pages Deployment
echo ====================================
echo.

REM Check if git is installed
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Git is not installed!
    echo Please install Git from: https://git-scm.com/download/win
    pause
    exit /b 1
)

echo Enter your GitHub username:
set /p GITHUB_USERNAME=

echo.
echo Your site will be at: https://%GITHUB_USERNAME%.github.io/valentine-pc/
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause >nul

echo.
echo Renaming valentine.html to index.html...
if exist valentine.html (
    copy valentine.html index.html >nul
    echo Done!
)

echo.
echo Initializing git repository...
git init

echo.
echo Adding files...
git add index.html style.css script.js

echo.
echo Creating commit...
git commit -m "Initial commit - Valentine's Day project 💝"

echo.
echo Setting up branch...
git branch -M main

echo.
echo Adding remote repository...
git remote add origin https://github.com/%GITHUB_USERNAME%/valentine-pc.git

echo.
echo Pushing to GitHub...
echo You may need to enter your GitHub credentials...
git push -u origin main

if %errorlevel% equ 0 (
    echo.
    echo ====================================
    echo SUCCESS! 🎉
    echo ====================================
    echo.
    echo Next steps:
    echo 1. Go to: https://github.com/%GITHUB_USERNAME%/valentine-pc
    echo 2. Click Settings ^> Pages
    echo 3. Under "Source", select "main" branch
    echo 4. Click Save
    echo.
    echo Your site will be live at:
    echo https://%GITHUB_USERNAME%.github.io/valentine-pc/
    echo.
    echo Wait 2-3 minutes for it to deploy!
    echo ====================================
) else (
    echo.
    echo ====================================
    echo ERROR during push
    echo ====================================
    echo.
    echo This might be because:
    echo 1. Repository doesn't exist yet - Create it at https://github.com/new
    echo 2. Authentication failed - Set up Git credentials
    echo 3. Remote already exists - Remove it with: git remote remove origin
    echo.
    echo See README-GITHUB-PAGES.md for detailed instructions
    echo ====================================
)

echo.
pause
