@echo off
set /p InstallUser=Enter schema that holds the sample business logic (must be FSM client or FSM owner):

set "InstallPWD=powershell.exe -Command " ^
$inputPass = read-host 'Enter password for %InstallUser%' -AsSecureString ; ^
$BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($inputPass); ^
[System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
for /f "tokens=*" %%a in ('%InstallPWD%') do set InstallPWD=%%a

set /p SID=Enter service name for the database or PDB:

set /p RemoteUser=Enter APEX schema that owns the APEX application:

set "RemotePWD=powershell.exe -Command " ^
$inputPass = read-host 'Enter password for %RemoteUser%' -AsSecureString ; ^
$BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($inputPass); ^
[System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
for /f "tokens=*" %%a in ('%RemotePWD%') do set RemotePWD=%%a

set /p ApexWorkspace=Enter name of APEX workspace:
set /p AppId=Enter the FSM application ID:


set nls_lang=GERMAN_GERMANY.AL32UTF8

sqlplus %RemoteUser%/%RemotePWD%@%SID% @install_scripts/uninstall_sample_app.sql %ApexWorkspace% %AppId%

sqlplus %InstallUser%/%InstallPWD%@%SID% @install_scripts/uninstall_sample.sql %RemoteUser%
