@echo off
pushd "%~dp0"
pip install --upgrade -r requirements.txt
popd
pause
exit /b
