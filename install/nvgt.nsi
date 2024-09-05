!execute "py nsis_genversion.py"
!include "nvgt_version.nsh"
!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "Integration.nsh"
!define /date COPYRIGHT_YEAR "%Y"
Name "nvgt"
Caption "NVGT - NonVisual Gaming Toolkit ${ver_string} setup"
OutFile "nvgt_${ver_filename_string}.exe"
RequestExecutionLevel admin
Unicode True
InstallDir C:\nvgt

var default_click_behavior ; 0 == run, 1 == edit

var click_dialog
var click_run
var click_edit

!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE "Welcome to the NonVisual Gaming Toolkit ${ver_string} Setup Program"
!define MUI_WELCOMEPAGE_TEXT "This program will guide you through the installation of the NonVisual Gaming Toolkit (NVGT), an open source audio game development engine designed to remove some of the low-level programming challenges inherent in audio game design.$\n$\n$_CLICK"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "license.txt"
!define MUI_COMPONENTSPAGE_NODESC
!insertmacro MUI_PAGE_COMPONENTS
Page custom show_default_click_behavior leave_default_click_behavior
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
  StrCpy $default_click_behavior 0
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
Section "Windows compilation stubs" SEC_WINDOWS
  SetOutPath $INSTDIR\stub
  File /a ..\release\stub\nvgt_windows*.bin
SectionEnd
!endif

!ifdef have_linux_stubs
Section /o "Linux cross-compilation stubs" SEC_LINUX
  SetOutPath $INSTDIR
  File /a /r ..\release\lib_linux
  SetOutPath $INSTDIR\stub
  File /a ..\release\stub\nvgt_linux*.bin
SectionEnd
!endif

!ifdef have_macos_stubs
Section /o "MacOS cross-compilation stubs" SEC_MACOS
  SetOutPath $INSTDIR
  File /a /r ..\release\lib_mac
  SetOutPath $INSTDIR\stub
  File /a ..\release\stub\nvgt_mac*.bin
SectionEnd
!endif

!ifdef have_android_stubs
Section /o "Android cross-compilation stubs" SEC_ANDROID
  SetOutPath $INSTDIR\stub
  File /a ..\release\stub\nvgt_android*.bin
SectionEnd
!endif

Section "File explorer context menu registration" SEC_CONTEXTMENU
  Var /GLOBAL sectionFlags
  DeleteRegKey HKCR ".nvgt"
  DeleteRegKey HKCR "NVGTScript"
  WriteRegStr HKCR ".nvgt" "" "NVGTScript"
  WriteRegStr HKCR ".nvgt" "PerceivedType" "text"
  WriteRegStr HKCR "NVGTScript" "" "NVGT Script"
  WriteRegStr HKCR "NVGTScript\DefaultIcon" "" ""
  WriteRegStr HKCR "NVGTScript\shell\compile" "MUIVerb" "Compile Script"
  WriteRegStr HKCR "NVGTScript\shell\compile" "ExtendedSubCommandsKey" ""
  WriteRegStr HKCR "NVGTScript\shell\compile" "SubCommands" ""
  !ifdef have_windows_stubs
    SectionGetFlags ${SEC_WINDOWS} $sectionFlags
    ${If} $sectionFlags & ${SF_SELECTED}
      WriteRegStr HKCR "NVGTScript\shell\compile\shell\windows_debug" "" "Windows (Debug)"
      WriteRegStr HKCR "NVGTScript\shell\compile\shell\windows_debug\command" "" '$INSTDIR\nvgtw.exe -pwindows -C "%1"'
      WriteRegStr HKCR "NVGTScript\shell\compile\shell\windows_release" "" "Windows (Release)"
      WriteRegStr HKCR "NVGTScript\shell\compile\shell\windows_release\command" "" '$INSTDIR\nvgtw.exe -pwindows -c "%1"'
    ${EndIf}
  !endif
  !ifdef have_macos_stubs
    SectionGetFlags ${SEC_MACOS} $sectionFlags
    ${If} $sectionFlags & ${SF_SELECTED}
      WriteRegStr HKCR "NVGTScript\shell\compile\shell\mac_debug" "" "MacOS (Debug)"
      WriteRegStr HKCR "NVGTScript\shell\compile\shell\mac_debug\command" "" '$INSTDIR\nvgtw.exe -pmac -C "%1"'
      WriteRegStr HKCR "NVGTScript\shell\compile\shell\mac_release" "" "MacOS (Release)"
      WriteRegStr HKCR "NVGTScript\shell\compile\shell\mac_release\command" "" '$INSTDIR\nvgtw.exe -pmac -c "%1"'
    ${EndIf}
  !endif
  !ifdef have_linux_stubs
    SectionGetFlags ${SEC_LINUX} $sectionFlags
    ${If} $sectionFlags & ${SF_SELECTED}
      WriteRegStr HKCR "NVGTScript\shell\compile\shell\linux_debug" "" "Linux (Debug)"
      WriteRegStr HKCR "NVGTScript\shell\compile\shell\linux_debug\command" "" '$INSTDIR\nvgtw.exe -plinux -C "%1"'
      WriteRegStr HKCR "NVGTScript\shell\compile\shell\linux_release" "" "Linux (Release)"
      WriteRegStr HKCR "NVGTScript\shell\compile\shell\linux_release\command" "" '$INSTDIR\nvgtw.exe -plinux -c "%1"'
    ${EndIf}
  !endif
  !ifdef have_android_stubs
    SectionGetFlags ${SEC_ANDROID} $sectionFlags
    ${If} $sectionFlags & ${SF_SELECTED}
      WriteRegStr HKCR "NVGTScript\shell\compile\shell\android_debug" "" "Android (Debug)"
      WriteRegStr HKCR "NVGTScript\shell\compile\shell\android_debug\command" "" '$INSTDIR\nvgtw.exe -pandroid -C "%1"'
      WriteRegStr HKCR "NVGTScript\shell\compile\shell\android_release" "" "Android (Release)"
      WriteRegStr HKCR "NVGTScript\shell\compile\shell\android_release\command" "" '$INSTDIR\nvgtw.exe -pandroid -c "%1"'
    ${EndIf}
  !endif
  WriteRegStr HKCR "NVGTScript\shell\edit" "" "Edit Script"
  WriteRegStr HKCR "NVGTScript\shell\edit\command" "" 'notepad "%1"'
  WriteRegStr HKCR "NVGTScript\shell\open" "" ""
  ${If} $default_click_behavior == 0
    WriteRegStr HKCR "NVGTScript\shell\open\command" "" '$INSTDIR\nvgtw.exe "%1"'
  ${Else}
    WriteRegStr HKCR "NVGTScript\shell\open\command" "" 'notepad "%1"'
  ${EndIf}
  WriteRegStr HKCR "NVGTScript\shell\run" "" "Run Script"
  WriteRegStr HKCR "NVGTScript\shell\run\command" "" '$INSTDIR\nvgtw.exe "%1"'
  WriteRegStr HKCR "NVGTScript\shell\debug" "" "Debug Script"
  WriteRegStr HKCR "NVGTScript\shell\debug\command" "" '$INSTDIR\nvgt.exe -d "%1"'
  ${NotifyShell_AssocChanged}
SectionEnd

Function show_default_click_behavior
    !insertmacro MUI_HEADER_TEXT_PAGE "Default Click Behavior" "Choose a default action for opening NVGT scripts"

    SectionGetFlags ${SEC_CONTEXTMENU} $0
    IntOp $0 $0 & ${SF_SELECTED}
    ${If} $0 = 0
        Abort ; Skip page if we aren't adding context menu handlers anyways
    ${EndIf}

    nsDialogs::Create 1018
    Pop $click_dialog

    ${If} $click_dialog == error
        Abort
    ${EndIf}

    ${NSD_CreateLabel} 0 0 100% 20u "Select the behavior you would prefer when clicking (pressing enter) on an NVGT script from Windows Explorer."
    ;Pop $0

    ${NSD_CreateFirstRadioButton} 0 30u 100% 10u "Run script"
    Pop $click_run
    ${NSD_CreateAdditionalRadioButton} 0 45u 100% 10u "Edit script"
    Pop $click_edit

    ${If} $default_click_behavior == 0
        ${NSD_SetState} $click_run ${BST_CHECKED}
        ${NSD_SetFocus} $click_run
    ${Else}
        ${NSD_SetState} $click_edit ${BST_CHECKED}
        ${NSD_SetFocus} $click_edit
    ${EndIf}

    nsDialogs::Show
FunctionEnd

Function leave_default_click_behavior
    ${NSD_GetState} $click_run $0
    ${If} $0 == ${BST_CHECKED}
        StrCpy $default_click_behavior 0
    ${Else}
        StrCpy $default_click_behavior 1
    ${EndIf}
FunctionEnd

Section "uninstall"
  RMDir /r $INSTDIR
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NVGT"
  DeleteRegKey HKLM "Software\Sam Tupy Productions\NVGT"
  DeleteRegKey /ifempty HKLM "Software\Sam Tupy Productions"
  DeleteRegKey HKCR ".nvgt"
  DeleteRegKey HKCR "NVGTScript"
SectionEnd
