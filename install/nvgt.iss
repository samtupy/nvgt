; NVGT - NonVisual Gaming Toolkit
; Copyright (c) 2022-2024 Sam Tupy and the NVGT developers
; [nvgt.gg](https://nvgt.gg)
;
; This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
; 2.  Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
; 3. This notice may not be removed or altered from any source distribution.
;
; File: nvgt.iss
; Description: NVGT InnoSetup installation utility

#expr Exec("py", "iss_genversion.py", ".", 1, SW_HIDE)
#include "nvgt_version.ish"

[Setup]
ASLRCompatible = yes
Compression = lzma2/ultra64
DEPCompatible = yes
OutputBaseFilename = NVGT_{#NVGTVerFilenameString}
SourceDir = ..
TerminalServicesAware = yes
UseSetupLdr = yes
AppMutex = NVGT
AppName = NVGT
AppVersion = {#NVGTVer}
ArchitecturesAllowed = x64compatible
ArchitecturesInstallIn64BitMode = x64compatible
ChangesAssociations = yes
ChangesEnvironment = yes
CreateAppDir = yes
CreateUninstallRegKey = yes
LicenseFile = install\license.txt
PrivilegesRequired = admin
SetupMutex = nvgtsetup
TimeStampRounding = 0
UsePreviousAppDir = yes
UsePreviousGroup = yes
UsePreviousLanguage = yes
UsePreviousPrivileges = yes
UsePreviousSetupType = yes
UsePreviousTasks = yes
UsePreviousUserInfo = yes
AppCopyright = Copyright (c) 2024 Sam Tupy and the NVGT developers
ShowTasksTreeLines = yes
WindowShowCaption = no
WizardStyle = modern
DefaultDirName = c:\nvgt
DefaultGroupName = NVGT
DisableFinishedPage = no
DisableStartupPrompt = yes
DisableWelcomePage = no
FlatComponentsList = yes
OutputDir = install
ShowLanguageDialog = yes
AlwaysShowComponentsList = yes
DisableReadyPage = yes

[Types]
Name: "custom"; Description: "Install only the components I select"; Flags: iscustom

[Components]
name: "core"; description: "NVGT compiler and interpreter"; flags: fixed; types: custom
name: "includes"; description: "Includes"; types: custom
name: "plugins"; description: "Optional plugins"; types: custom
name: "plugins\curl"; description: "CURL"; types: custom
name: "plugins\git"; description: "Git"; types: custom
name: "plugins\sqlite"; description: "SQLite3"; types: custom
name: "plugins\systemd_notify"; description: "systemd-notify"; types: custom
name: "stubs"; description: "Stubs"; types: custom
#ifdef have_windows_stubs
name: "stubs\windows"; description: "Windows binary stub"; types: custom
#endif
#ifdef have_macos_stubs
name: "stubs\macos"; description: "MacOS binary stub"; types: custom
#endif
#ifdef have_linux_stubs
name: "stubs\linux"; description: "Linux binary stub"; types: custom
#endif
#ifdef have_android_stubs
name: "stubs\android"; description: "Android binary stub"; types: custom
name: "androidtools"; description: "Android tools (external download required)"; types: custom
#endif
#ifdef have_docs
name: "docs"; description: "Documentation"; types: custom
#else
name: "docs_download"; description: "Documentation (external download required)"; types: custom
#endif
name: "associate"; description: "File associations and context menus"
name: "associate\edit"; description: "Open NVGT scripts in the default text editor"; flags: exclusive
name: "associate\run"; description: "Execute NVGT scripts within NVGT"; flags: exclusive; types: custom
name: "path"; description: "Add NVGT to the PATH environment variable"; types: custom

[Files]
; Core
Source: "release\nvgt.exe"; DestDir: "{app}"
Source: "release\nvgtw.exe"; DestDir: "{app}"
source: "release\lib\*.dll"; DestDir: "{app}\lib"
; Plugins: curl
source: "release\lib\nvgt_curl.dll"; DestDir: "{app}\lib"; components: plugins\curl
; Plugins: git
source: "release\lib\git2.dll"; DestDir: "{app}\lib"; components: plugins\git
source: "release\lib\git2nvgt.dll"; DestDir: "{app}\lib"; components: plugins\git
; Plugins: sqlite
source: "release\lib\nvgt_sqlite.dll"; DestDir: "{app}\lib"; components: plugins\sqlite
; Plugins: systemd-notify
source: "release\lib\systemd_notify.dll"; DestDir: "{app}\lib"; components: plugins\systemd_notify
; Stubs
#ifdef have_windows_stubs
source: "release\stub\nvgt_windows*.bin"; DestDir: "{app}\stub"; components: stubs\windows
#endif
#ifdef have_macos_stubs
source: "release\stub\nvgt_mac.bin"; DestDir: "{app}\stub"; components: stubs\macos
source: "release\lib_mac\*"; DestDir: "{app}\lib_mac"; components: stubs\macos
#endif
#ifdef have_linux_stubs
source: "release\stub\nvgt_linux*.bin"; DestDir: "{app}\stub"; components: stubs\linux
source: "release\lib_linux\*"; DestDir: "{app}\lib_linux"; components: stubs\linux
#endif
#ifdef have_android_stubs
source: "release\stub\nvgt_android.bin"; DestDir: "{app}\stub"; components: stubs\android
#endif
; Includes
source: "release\include\*.nvgt"; DestDir: "{app}\include"; components: includes
#ifdef have_docs
source: "doc\nvgt.chm"; DestDir: "{app}"; components: docs
#endif

[Registry]
Root: HKA; subkey: "software\classes\.nvgt"; ValueType: string; ValueName: ""; ValueData: "NVGTScript"; Flags: uninsdeletevalue; components: associate
Root: HKA; subkey: "software\classes\NVGTScript"; ValueType: string; ValueName: ""; ValueData: "NVGT Script"; Flags: uninsdeletekey; components: associate
Root: HKA; subkey: "software\classes\NVGTScript\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\nvgtw.exe,0"; components: associate
Root: HKA; subkey: "software\classes\NVGTScript\shell\compile"; ValueType: string; ValueName: "MUIVerb"; ValueData: "Compile Script"; components: associate
Root: HKA; subkey: "software\classes\NVGTScript\shell\compile"; ValueType: string; ValueName: "ExtendedSubCommandsKey"; ValueData: ""; components: associate
Root: HKA; subkey: "software\classes\NVGTScript\shell\compile"; ValueType: string; ValueName: "SubCommands"; ValueData: ""; components: associate
#ifdef have_windows_stubs
root: HKA; subkey: "software\classes\NVGTScript\shell\compile\shell\windows_debug"; ValueType: string; ValueName: ""; ValueData: "Windows (Debug)"; components: associate
root: HKA; subkey: "software\classes\NVGTScript\shell\compile\shell\windows_debug\command"; ValueType: string; ValueName: ""; ValueData: "{app}\nvgtw.exe -pwindows -C ""%1"""; components: associate
root: HKA; subkey: "software\classes\NVGTScript\shell\compile\shell\windows_release"; ValueType: string; ValueName: ""; ValueData: "Windows (Release)"; components: associate
root: HKA; subkey: "software\classes\NVGTScript\shell\compile\shell\windows_release\command"; ValueType: string; ValueName: ""; ValueData: "{app}\nvgtw.exe -pwindows -c ""%1"""; components: associate
#endif
#ifdef have_macos_stubs
root: HKA; subkey: "software\classes\NVGTScript\shell\compile\shell\mac_debug"; ValueType: string; ValueName: ""; ValueData: "MacOS (Debug)"; components: associate
root: HKA; subkey: "software\classes\NVGTScript\shell\compile\shell\mac_debug\command"; ValueType: string; ValueName: ""; ValueData: "{app}\nvgtw.exe -pmac -C ""%1"""; components: associate
root: HKA; subkey: "software\classes\NVGTScript\shell\compile\shell\mac_release"; ValueType: string; ValueName: ""; ValueData: "MacOS (Release)"; components: associate
root: HKA; subkey: "software\classes\NVGTScript\shell\compile\shell\mac_release\command"; ValueType: string; ValueName: ""; ValueData: "{app}\nvgtw.exe -pmac -c ""%1"""; components: associate
#endif
#ifdef have_linux_stubs
root: HKA; subkey: "software\classes\NVGTScript\shell\compile\shell\linux_debug"; ValueType: string; ValueName: ""; ValueData: "Linux (Debug)"; components: associate
root: HKA; subkey: "software\classes\NVGTScript\shell\compile\shell\linux_debug\command"; ValueType: string; ValueName: ""; ValueData: "{app}\nvgtw.exe -plinux -C ""%1"""; components: associate
root: HKA; subkey: "software\classes\NVGTScript\shell\compile\shell\linux_release"; ValueType: string; ValueName: ""; ValueData: "Linux (Release)"; components: associate
root: HKA; subkey: "software\classes\NVGTScript\shell\compile\shell\linux_release\command"; ValueType: string; ValueName: ""; ValueData: "{app}\nvgtw.exe -plinux -c ""%1"""; components: associate
#endif
#ifdef have_android_stubs
root: HKA; subkey: "software\classes\NVGTScript\shell\compile\shell\android_debug"; ValueType: string; ValueName: ""; ValueData: "Android (Debug)"; components: associate
root: HKA; subkey: "software\classes\NVGTScript\shell\compile\shell\android_debug\command"; ValueType: string; ValueName: ""; ValueData: "{app}\nvgtw.exe -pandroid -C ""%1"""; components: associate
root: HKA; subkey: "software\classes\NVGTScript\shell\compile\shell\android_release"; ValueType: string; ValueName: ""; ValueData: "Android (Release)"; components: associate
root: HKA; subkey: "software\classes\NVGTScript\shell\compile\shell\android_release\command"; ValueType: string; ValueName: ""; ValueData: "{app}\nvgtw.exe -pandroid -c ""%1"""; components: associate
#endif
Root: HKA; subkey: "software\classes\NVGTScript\shell\edit"; ValueType: string; ValueName: ""; ValueData: "Edit Script"; components: associate
Root: HKA; subkey: "software\classes\NVGTScript\shell\edit\command"; ValueType: string; ValueName: ""; ValueData: """notepad"" ""%1"""; components: associate
Root: HKA; subkey: "software\classes\NVGTScript\shell\open\command"; ValueType: string; ValueName: ""; ValueData: "{app}\nvgtw.exe ""%1"""; components: associate\run
Root: HKA; subkey: "software\classes\NVGTScript\shell\open\command"; ValueType: string; ValueName: ""; ValueData: "notepad ""%1"""; components: associate\edit
Root: HKA; subkey: "software\classes\NVGTScript\shell\run"; ValueType: string; ValueName: ""; ValueData: "Run Script"; components: associate
Root: HKA; subkey: "software\classes\NVGTScript\shell\run\command"; ValueType: string; ValueName: ""; ValueData: """{app}\nvgtw.exe"" ""%1"""; components: associate
Root: HKA; subkey: "software\classes\NVGTScript\shell\debug"; ValueType: string; ValueName: ""; ValueData: "Debug Script"; components: associate
Root: HKA; subkey: "software\classes\NVGTScript\shell\debug\command"; ValueType: string; ValueName: ""; ValueData: """{app}\nvgt.exe"" -d ""%1"""; components: associate
    
[Icons]
Name: "{group}\NVGT Interpreter (GUI mode)"; Filename: "{app}\nvgtw.exe"
Name: "{group}\NVGT Documentation"; Filename: "{app}\nvgt.chm"

[UninstallDelete]
type: filesandordirs; name: "{app}\android-tools"
type: filesandordirs; name: "{app}\lib_mac"
type: filesandordirs; name: "{app}\lib_linux"
type: filesandordirs; name: "{app}\lib"
type: filesandordirs; name: "{app}\stub"
type: files; name: "{app}\nvgt.chm"

[Run]
Filename: "{app}\nvgtw.exe"; description: "Run NVGT interpreter"; flags: postinstall nowait runasoriginaluser
filename: "{app}\nvgt.chm"; description: "View documentation"; verb: "open"; flags: postinstall shellexec nowait runasoriginaluser
filename: "https://nvgt.gg"; description: "View NVGT website"; verb: "open"; flags: postinstall shellexec nowait runasoriginaluser

[Messages]
SelectDirBrowseLabel = Select the directory in which you would like NVGT to be installed, then click Next to proceed. If you wish to browse for it, click Browse.
SelectStartMenuFolderBrowseLabel = Select the start menu group where you would like NVGT's start menu icons to be placed, then click Next to proceed. If you wish to browse for it, click Browse.

[Code]
var
AndroidSdkDownloadPage, DocsDownloadPage: TDownloadWizardPage;
 
const
  EnvironmentKey = 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment';

procedure EnvAddPath(Path: string);
var
    Paths: string;
begin
    // Retrieve current path (use empty string if entry not exists)
    if not RegQueryStringValue(HKLM, EnvironmentKey, 'Path', Paths)
    then Paths := '';

    // Skip if string already found in path
    if Pos(';' + Uppercase(Path) + ';', ';' + Uppercase(Paths) + ';') > 0 then exit;

    // Append string to the end of the path variable
    Paths := Paths + ';'+ Path +';'

    // Overwrite (or create if missing) path environment variable
    if RegWriteStringValue(HKLM, EnvironmentKey, 'Path', Paths)
    then Log(Format('The [%s] added to PATH: [%s]', [Path, Paths]))
    else Log(Format('Error while adding the [%s] to PATH: [%s]', [Path, Paths]));
end;

procedure EnvRemovePath(Path: string);
var
    Paths: string;
    P: Integer;
begin
    // Skip if registry entry not exists
    if not RegQueryStringValue(HKLM, EnvironmentKey, 'Path', Paths) then
        exit;

    // Skip if string not found in path
    P := Pos(';' + Uppercase(Path) + ';', ';' + Uppercase(Paths) + ';');
    if P = 0 then exit;

    // Update path variable
    Delete(Paths, P - 1, Length(Path) + 1);

    // Overwrite path environment variable
    if RegWriteStringValue(HKLM, EnvironmentKey, 'Path', Paths)
    then Log(Format('The [%s] removed from PATH: [%s]', [Path, Paths]))
    else Log(Format('Error while removing the [%s] from PATH: [%s]', [Path, Paths]));
end;

function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  if Progress = ProgressMax then
    Log(Format('Successfully downloaded file to {tmp}: %s', [FileName]));
  Result := True;
end;

procedure InitializeWizard;
begin
  AndroidSdkDownloadPage := CreateDownloadPage('Downloading Android tools', 'Please wait while the subset of the Android SDK that NVGT uses is being downloaded', @OnDownloadProgress);
  AndroidSdkDownloadPage.ShowBaseNameInsteadOfUrl := True;
  DocsDownloadPage := CreateDownloadPage('Downloading documentation', 'Please wait while the documentation is acquired', @OnDownloadProgress);
  DocsDownloadPage.ShowBaseNameInsteadOfUrl := True;
end;

procedure CurPageChanged(CurPageID: Integer);
var
  IsInstalled: Boolean;
begin
  IsInstalled := DirExists(WizardDirValue());
  if (CurPageID in [wpSelectProgramGroup, wpReady]) or (IsInstalled and (CurPageID = wpSelectComponents)) then
    WizardForm.NextButton.Caption := SetupMessage(msgButtonInstall)
  else if CurPageID = wpFinished then
    WizardForm.NextButton.Caption := SetupMessage(msgButtonFinish)
  else
    WizardForm.NextButton.Caption := SetupMessage(msgButtonNext);
end;

procedure DownloadAndroidSDK;
var
  ErrorCode: Integer;
begin
AndroidSdkDownloadPage.Clear;
AndroidSdkDownloadPage.Add('https://nvgt.gg/downloads/android-tools.exe', 'android-tools.exe', '');
AndroidSdkDownloadPage.Show;
try
try
AndroidSdkDownloadPage.Download;
except
if AndroidSdkDownloadPage.AbortedByUser then
SuppressibleMsgBox('The Android tools installation was aborted. You will not be able to create Android apps with this installation unless you download the tools in the future.', mbInformation, MB_OK, IDOK)
else
SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbCriticalError, MB_OK, IDOK);
end;
finally
AndroidSdkDownloadPage.Hide;
if not ShellExec('', ExpandConstant('{tmp}\android-tools.exe'), ExpandConstant('-o{app}\android-tools -y'), '', SW_SHOWNORMAL, ewWaitUntilTerminated, ErrorCode) then
begin
SuppressibleMsgBox(Format('An error occurred when extracting the android tools: %s', [SysErrorMessage(ErrorCode)]), mbCriticalError, MB_OK, IDOK);
exit;
end;
end;
end;

procedure DownloadDocs;
begin
DocsDownloadPage.Clear;
DocsDownloadPage.Add('https://nvgt.gg/docs/nvgt.chm', 'nvgt.chm', '');
DocsDownloadPage.Show;
try
try
DocsDownloadPage.Download;
        if not FileCopy(ExpandConstant('{tmp}\nvgt.chm'), ExpandConstant('{app}\nvgt.chm'), false) then
        begin
            MsgBox(Format('Could not copy %s to %s', [ExpandConstant('{tmp}\nvgt.chm'), ExpandConstant('{app}\nvgt.chm')]), MbCriticalError, MB_OK);
            abort;
        end;
except
if DocsDownloadPage.AbortedByUser then
SuppressibleMsgBox('Downloading of the documentation was cancelled. This installation may have broken shortcuts pointing to documentation.', mbInformation, MB_OK, IDOK)
else
SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbCriticalError, MB_OK, IDOK);
end;
finally
DocsDownloadPage.Hide;
end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
if WizardIsComponentSelected('androidtools') then
DownloadAndroidSDK;
if WizardIsComponentSelected('docs_download') then
DownloadDocs;
if WizardIsComponentSelected('path') then
EnvAddPath(ExpandConstant('{app}'));
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
    if CurUninstallStep = usPostUninstall then
        EnvRemovePath(ExpandConstant('{app}'));
end;
