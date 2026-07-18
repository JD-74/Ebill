[Setup]
AppName=Ebill
AppVersion=4.3.0
DefaultDirName={pf}\Ebill
DefaultGroupName=Ebill
OutputDir=landing\downloads
OutputBaseFilename=ebill-4.3.0-windows-setup
Compression=lzma
SolidCompression=yes

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\Ebill"; Filename: "{app}\ebill.exe"
Name: "{commondesktop}\Ebill"; Filename: "{app}\ebill.exe"
