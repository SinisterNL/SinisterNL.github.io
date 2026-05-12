@echo off
cd /d C:\Sites\sinisternl
"C:\Program Files\Git\cmd\git.exe" add -A
"C:\Program Files\Git\cmd\git.exe" commit -m "Fix wrangler.jsonc: restore main + ASSETS binding + route"
"C:\Program Files\Git\cmd\git.exe" pull --rebase --strategy-option=ours
"C:\Program Files\Git\cmd\git.exe" push
echo DONE
