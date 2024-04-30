@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
git add .
git commit --amend --reuse-message=HEAD
git push --force
)

