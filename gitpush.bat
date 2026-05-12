@echo off
cd /d C:\Sites\sinisternl
"C:\Program Files\Git\cmd\git.exe" add -A
"C:\Program Files\Git\cmd\git.exe" commit -m "Fix deploy: use explicit wrangler secret put instead of action secrets"
"C:\Program Files\Git\cmd\git.exe" push
echo DONE
