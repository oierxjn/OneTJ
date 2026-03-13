[Setup]
AppId={{e52df8a9-9166-40d9-ad95-a4d5880b9a0f}}
AppName=OneTJ
AppVersion=2.2.4
DefaultDirName={localappdata}\Programs\OneTJ
DefaultGroupName=OneTJ
OutputDir=dist
OutputBaseFilename=OneTJSetup
Compression=lzma
SolidCompression=yes
SetupIconFile=assets\icon\logo.ico

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{group}\OneTJ"; Filename: "{app}\onetj.exe"
Name: "{commondesktop}\OneTJ"; Filename: "{app}\onetj.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"; Flags: unchecked

[Run]
Filename: "{app}\onetj.exe"; Description: "Run OneTJ"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{userappdata}\onetj\hive"
Type: filesandordirs; Name: "{userappdata}\onetj\logs"
Type: filesandordirs; Name: "{localappdata}\OneTJ\EBWebView"
Type: dirifempty; Name: "{userappdata}\onetj"
Type: dirifempty; Name: "{localappdata}\OneTJ"
