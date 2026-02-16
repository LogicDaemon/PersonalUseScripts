@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS

git diff --cached --quiet || git add .
git commit --amend --reuse-message=HEAD
git push --force-with-lease
)
