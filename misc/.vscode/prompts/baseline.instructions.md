---
description: Always
applyTo: '*'
---

VS Code requres approvals for all CLI operations except whitelisted ones.
The current auto-approve is following:
```
/.venv\\Scripts\\Activate(\\.(ps1|bat))?$
/^(.*\\)?python(\\.exe)? -m py_compile$/
/^gh(\\.exe)? run (list|view|watch)\\b/
/^go(\\.exe)? (doc|test|build)\\b/
/^helm (get|show|list|status)\\b/
/^jj(\\.exe)? (--help|bisect|b(ookmark)?|commit|ci|describe|(evo)?log|fix|help|(inter)?diff|new|next|parallelize|prev|rebase|redo|restore|revert|(workspace )?root|show|simplify-parents|sparse|split|squash|status|tag|undo|version)\\b/
/^knife(\\.bat)? (search|node show)\\b/
/^terraform(\\.exe)?( -chdir=\\S+| (\"-chdir=|-chdir=\")[^\"]+\"| ('-chdir=|-chdir=')[^']+')? (init|validate|fmt|plan|providers schema)( -parallelism=\\d+| -target=\\S+| ('-target=|-target=')[^']+')*/
/^tsh(\\.exe)? kubectl (get|describe|logs)\\b/
/^git(\\.exe)?( -C (\\w+|\"[^\"]+\"))? (diff|grep|log|show|status)\\b/
/^git(\\.exe)?( -C (\\w+|\"[^\"]+\"))? remote( -v)?$/
/^git(\\.exe)?( -C (\\w+|\"[^\"]+\"))? (rev-parse|ls-remote|ls-tree)/
/^git(\\.exe)?( -C (\\w+|\"[^\"]+\"))? branch( (-v|--show-current))?$/
/^python(\\.exe)? main\\.py (--action|-a)\\b/
/^vault(\\.exe)? (policy read|auth list)$
cat
cd
dir
findstr
gofmt
grep
head
ls
rg
tail
type
wc
ConvertFrom-Json
Get-ChildItem
Get-Content
Get-Location
Measure-Object
Out-String
Pop-Location
Push-Location
Select-Object
Select-String
Set-Location
Sort-Object
Where-Object
Write-Host
ForEach-Object
diff
echo
more
```
Please avoid commands outside of this list.
