Name "NVGT - NonVisual Gaming Toolkit"
OutFile "nvgt_installer.exe"
RequestExecutionLevel admin
Unicode True
InstallDir C:\nvgt

Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

Section ""
  SetOutPath $INSTDIR
  File /a /r ..\release\*
  File ..\doc\nvgt.chm
SectionEnd
