@echo off
echo Creating GitHub repository...
echo.
echo Please create a new repository on GitHub:
echo 1. Go to https://github.com/new
echo 2. Repository name: youth-policy-v2
echo 3. Description: 청년 정책 교육 플랫폼 V2
echo 4. Public
echo 5. Do NOT initialize with README
echo.
echo Press any key when repository is created...
pause
echo.
echo Enter your GitHub username:
set /p username=
echo.
git remote add origin https://github.com/%username%/youth-policy-v2.git
git branch -M main
git push -u origin main
echo.
echo Done! Repository pushed to GitHub.
pause
