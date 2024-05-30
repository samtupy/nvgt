!execute "py nsis_genversion.py"
!include "nvgt_version.nsh"
!include "MUI2.nsh"
!include "Integration.nsh"
!define /date COPYRIGHT_YEAR "%Y"
Name "nvgt"
Caption "NVGT - NonVisual Gaming Toolkit ${ver_string} setup"
OutFile "nvgt_${ver_filename_string}.exe"
RequestExecutionLevel admin
Unicode True
InstallDir C:\nvgt

!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE "Welcome to the NonVisual Gaming Toolkit ${ver_string} Setup Program"
!define MUI_WELCOMEPAGE_TEXT "This program will guide you through the installation of the NonVisual Gaming Toolkit (NVGT), an open source audio game development engine designed to remove some of the low-level programming challenges inherent in audio game design.$\n$\n$_CLICK"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "license.txt"
!define MUI_COMPONENTSPAGE_NODESC
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_LINK "Visit the NVGT &website"
!define MUI_FINISHPAGE_LINK_LOCATION "https://nvgt.gg/"
!define MUI_FINISHPAGE_SHOWREADME $INSTDIR\nvgt.chm
!define MUI_FINISHPAGE_SHOWREADME_TEXT "View &documentation"
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

;Version Information
  VIProductVersion "${ver}.0"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "NVGT"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" "https://nvgt.gg"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "Sam Tupy Productions and contributors"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "Copyright 2022-${COPYRIGHT_YEAR} Sam Tupy  Productions and contributors"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "NonVisual Gaming Toolkit"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${ver}"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductVersion" "${ver}"

Function .onInit
  SetRegView 64
  ReadRegStr $0 HKLM "Software\Sam Tupy Productions\NVGT" ""
  ${If} $0 != ""
    StrCpy $INSTDIR $0
  ${EndIf}
FunctionEnd
Function un.onInit
  SetRegView 64
FunctionEnd

Section "-NVGT"
  SetOutPath $INSTDIR
  File /a /r ..\release\lib
  File /a ..\release\*
  File ..\doc\nvgt.chm
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NVGT"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NVGT" "DisplayName" "NonVisual Gaming Toolkit (NVGT)"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NVGT" "DisplayVersion" ${ver_string}
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NVGT" "Publisher" "Sam Tupy Productions and contributors"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NVGT" "UninstallString" $INSTDIR\uninst.exe
  WriteRegStr HKLM "Software\Sam Tupy Productions\NVGT" "" $INSTDIR
  WriteUninstaller "$INSTDIR\uninst.exe"
SectionEnd

Section "Bundled include scripts"
  SetOutPath $INSTDIR
  File /a /r ..\release\include
SectionEnd

!ifdef have_windows_stubs
Section "Windows compilation stubs"
  SetOutPath $INSTDIR\stub
  File /a ..\release\stub\nvgt_windows*.bin
SectionEnd
!endif

!ifdef have_linux_stubs
Section /o "Linux cross-compilation stubs"
  SetOutPath $INSTDIR\stub
  File /a ..\release\stub\nvgt_linux*.bin
SectionEnd
!endif

!ifdef have_macos_stubs
Section /o "MacOS cross-compilation stubs"
  SetOutPath $INSTDIR\stub
  File /a ..\release\stub\nvgt_mac*.bin
SectionEnd
!endif

Section "File explorer context menu registration"
  DeleteRegKey HKCR ".nvgt"
  DeleteRegKey HKCR "NVGTScript"
  WriteRegStr HKCR ".nvgt" "" "NVGTScript"
  WriteRegStr HKCR ".nvgt" "PerceivedType" "text"
  WriteRegStr HKCR "NVGTScript" "" "NVGT Script"
  WriteRegStr HKCR "NVGTScript\DefaultIcon" "" ""
  WriteRegStr HKCR "NVGTScript\shell\compile" "MUIVerb" "Compile Script"
  WriteRegStr HKCR "NVGTScript\shell\compile" "ExtendedSubCommandsKey" ""
  WriteRegStr HKCR "NVGTScript\shell\compile" "SubCommands" ""
  WriteRegStr HKCR "NVGTScript\shell\compile\shell\debug" "" "Debug"
  WriteRegStr HKCR "NVGTScript\shell\compile\shell\debug\command" "" '$INSTDIR\nvgtw.exe -C "%1"'
  WriteRegStr HKCR "NVGTScript\shell\compile\shell\release" "" "Release"
  WriteRegStr HKCR "NVGTScript\shell\compile\shell\release\command" "" '$INSTDIR\nvgtw.exe -c "%1"'
  WriteRegStr HKCR "NVGTScript\shell\edit" "" "Edit Script"
  WriteRegStr HKCR "NVGTScript\shell\edit\command" "" 'notepad "%1"'
  WriteRegStr HKCR "NVGTScript\shell\open" "" ""
  WriteRegStr HKCR "NVGTScript\shell\open\command" "" '$INSTDIR\nvgtw.exe "%1"'
  WriteRegStr HKCR "NVGTScript\shell\run" "" "Run Script"
  WriteRegStr HKCR "NVGTScript\shell\run\command" "" '$INSTDIR\nvgtw.exe "%1"'
  WriteRegStr HKCR "NVGTScript\shell\debug" "" "Debug Script"
  WriteRegStr HKCR "NVGTScript\shell\debug\command" "" '$INSTDIR\nvgt.exe -d "%1"'
  ${NotifyShell_AssocChanged}
SectionEnd

Section "uninstall"
  RMDir /r $INSTDIR
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NVGT"
  DeleteRegKey HKLM "Software\Sam Tupy Productions\NVGT"
  DeleteRegKey /ifempty HKLM "Software\Sam Tupy Productions"
  DeleteRegKey HKCR ".nvgt"
  DeleteRegKey HKCR "NVGTScript"
SectionEnd
