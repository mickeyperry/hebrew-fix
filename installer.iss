; HebrewFix installer — build with: ISCC.exe installer.iss  (or run build.ps1)
#define AppName "HebrewFix"
#define AppVersion "1.0.1"
#define AppExe "HebrewFix.exe"

[Setup]
AppId={{6E0B6F1A-4C2D-4B7E-9A51-2F1D3C8E7A10}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher=Mickey Perry
AppPublisherURL=https://github.com/mickeyperry/hebrew-fix
AppSupportURL=https://github.com/mickeyperry/hebrew-fix/issues
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputDir=dist
OutputBaseFilename=HebrewFix-Setup
SetupIconFile=icon.ico
UninstallDisplayIcon={app}\{#AppExe}
WizardStyle=modern
WizardSmallImageFile=build\wizsmall.bmp
Compression=lzma2/max
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
CloseApplications=force
VersionInfoVersion={#AppVersion}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "hebrew"; MessagesFile: "compiler:Languages\Hebrew.isl"

[CustomMessages]
english.StartupTask=Start {#AppName} with Windows
hebrew.StartupTask=הפעל את {#AppName} עם Windows
english.LaunchApp=Launch {#AppName} now
hebrew.LaunchApp=הפעל את {#AppName} עכשיו
english.HowTo=How to use
hebrew.HowTo=הוראות שימוש

[Tasks]
Name: "startup"; Description: "{cm:StartupTask}"
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\{#AppExe}"; DestDir: "{app}"; Flags: ignoreversion
Source: "README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "LICENSE"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExe}"
Name: "{group}\{cm:HowTo}"; Filename: "https://github.com/mickeyperry/hebrew-fix#how-to-use"
Name: "{group}\{cm:UninstallProgram,{#AppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon
; Same shortcut name the app's own "Start with Windows" tray toggle uses
Name: "{userstartup}\{#AppName}"; Filename: "{app}\{#AppExe}"; WorkingDir: "{app}"; Tasks: startup

[Run]
Filename: "{app}\{#AppExe}"; Description: "{cm:LaunchApp}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: files; Name: "{userstartup}\{#AppName}.lnk"
Type: filesandordirs; Name: "{userappdata}\{#AppName}"

[Code]
procedure KillApp();
var
  RC: Integer;
begin
  Exec(ExpandConstant('{sys}\taskkill.exe'), '/F /IM {#AppExe}', '', SW_HIDE, ewWaitUntilTerminated, RC);
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  KillApp();
  Result := '';
end;

function InitializeUninstall(): Boolean;
begin
  KillApp();
  Result := True;
end;
