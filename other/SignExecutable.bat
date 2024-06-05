@echo off
"C:\Program Files (x86)\Windows Kits\10\bin\10.0.18362.0\x64\signtool.exe" sign /fd sha256 /d "Application Description" /du "https://application.website" /a "application.exe"
pause
