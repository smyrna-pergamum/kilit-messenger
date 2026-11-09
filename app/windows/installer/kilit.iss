; The Windows installer for Kilit (Inno Setup 6). It installs for the current
; user only, needs no administrator rights, and puts Kilit in
; %LOCALAPPDATA%\Programs\Kilit with its own Tor beside it.
;
; Build the app first (flutter build windows --release, with Tor fetched by
; scripts\fetch-tor-windows.ps1), then from app\windows\installer:
;
;   ISCC.exe /DAppVersion=0.1.4-alpha kilit.iss
;
; Uninstalling leaves the vault (%APPDATA%\app.kilit) where it is: removing
; the program must not quietly remove someone's messages. Kilit's panic code
; is the way to wipe it.

#ifndef AppVersion
  #define AppVersion "0.0.0-dev"
#endif
#define Release "..\..\build\windows\x64\runner\Release"

[Setup]
; never change: Windows knows the installed Kilit by it
AppId={{448C48B5-8590-4F53-82B9-38916E0F0C98}
AppName=Kilit
AppVersion={#AppVersion}
AppVerName=Kilit {#AppVersion}
AppPublisher=Kilit contributors
AppPublisherURL=https://github.com/smyrna-pergamum/kilit-messenger
AppSupportURL=https://github.com/smyrna-pergamum/kilit-messenger/issues
AppUpdatesURL=https://github.com/smyrna-pergamum/kilit-messenger/releases
DefaultDirName={autopf}\Kilit
DefaultGroupName=Kilit
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
LicenseFile=..\..\..\LICENSE
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\kilit.exe
UninstallDisplayName=Kilit
OutputDir=..\..\build\installer
OutputBaseFilename=Kilit-{#AppVersion}-windows-setup
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
; a running Kilit (and its Tor) is closed before files are replaced
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "tr"; MessagesFile: "compiler:Languages\Turkish.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#Release}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Kilit"; Filename: "{app}\kilit.exe"
Name: "{autodesktop}\Kilit"; Filename: "{app}\kilit.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\kilit.exe"; Description: "{cm:LaunchProgram,Kilit}"; Flags: nowait postinstall skipifsilent
; no tor.exe to stop on uninstall: Kilit's Tor ends with Kilit
; (__OwningControllerProcess), and stopping tor.exe by name would also stop
; someone's Tor Browser
