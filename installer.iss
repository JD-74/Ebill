[Setup]
AppName=Ebill
AppVersion=1.0.0
DefaultDirName={pf}\Ebill
DefaultGroupName=Ebill
OutputDir=Output
OutputBaseFilename=EbillSetup
Compression=lzma
SolidCompression=yes

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\Ebill"; Filename: "{app}\ebill.exe"
Name: "{commondesktop}\Ebill"; Filename: "{app}\ebill.exe"
