[Setup]
AppName=OneTJ
AppVersion=2.0.0
DefaultDirName={pf}\OneTJ
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
