@echo off
call make.bat clean
call make.bat html
.\build\html\index.html
pause
