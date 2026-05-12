@echo off
cd /d C:\Sites\sinisternl
"C:\Program Files\Git\cmd\git.exe" add -A
"C:\Program Files\Git\cmd\git.exe" commit -m "Show actual AI error message for diagnosis"
"C:\Program Files\Git\cmd\git.exe" push
echo DONE
