@echo off
cd /d C:\Sites\sinisternl
"C:\Program Files\Git\cmd\git.exe" add -A
"C:\Program Files\Git\cmd\git.exe" commit -m "Fix: rename GITHUB_TOKEN to GH_TOKEN (reserved name conflict)"
"C:\Program Files\Git\cmd\git.exe" push
echo DONE
