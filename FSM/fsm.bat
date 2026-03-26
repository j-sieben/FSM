@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "COMMAND=%~1"
if "%COMMAND%"=="" set "COMMAND=help"
if not "%~1"=="" shift

if /i "%COMMAND%"=="help" goto :help
if /i "%COMMAND%"=="install" goto :install
if /i "%COMMAND%"=="install-client" goto :install_client
if /i "%COMMAND%"=="install-sample" goto :install_sample
if /i "%COMMAND%"=="uninstall" goto :uninstall
if /i "%COMMAND%"=="uninstall-client" goto :uninstall_client
if /i "%COMMAND%"=="uninstall-sample" goto :uninstall_sample

echo ERROR: Unknown command %COMMAND%
exit /b 1

:help
echo Usage:
echo   fsm.bat ^<command^>
echo.
echo Commands:
echo   install
echo   install-client
echo   install-sample
echo   uninstall
echo   uninstall-client
echo   uninstall-sample
echo   help
echo.
echo Use fsm.sh for the full CLI option set on Unix-like systems.
exit /b 0

:read_secret
set "SECRET_VAR=%~1"
set "SECRET_PROMPT=%~2"
set "SECRET_CMD=powershell.exe -Command "$inputPass = Read-Host '%SECRET_PROMPT%' -AsSecureString; $BSTR=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($inputPass); [Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
for /f "tokens=*" %%a in ('%SECRET_CMD%') do set "%SECRET_VAR%=%%a"
exit /b 0

:require_value
set "REQ_NAME=%~1"
set "REQ_PROMPT=%~2"
if defined %REQ_NAME% exit /b 0
set /p %REQ_NAME%=%REQ_PROMPT%
if defined %REQ_NAME% exit /b 0
echo ERROR: Missing required value %REQ_NAME%
exit /b 1

:require_secret
set "REQ_NAME=%~1"
set "REQ_PROMPT=%~2"
if defined %REQ_NAME% exit /b 0
call :read_secret %REQ_NAME% "%REQ_PROMPT%"
if defined %REQ_NAME% exit /b 0
echo ERROR: Missing required secret %REQ_NAME%
exit /b 1

:run_sqlplus
set "DB_USER=%~1"
set "DB_PASSWORD=%~2"
set "DB_SERVICE=%~3"
set "SQL_SCRIPT=%~4"
shift
shift
shift
shift
sqlplus -s /nolog @%SCRIPT_DIR%install_scripts\sqlplus_runner.sql "%DB_USER%" "%DB_PASSWORD%" "%DB_SERVICE%" "%SQL_SCRIPT%" %*
exit /b %ERRORLEVEL%

:install
if not defined FSM_OWNER set "FSM_OWNER="
if not defined FSM_OWNER_PW set "FSM_OWNER_PW="
if not defined FSM_SERVICE set "FSM_SERVICE="
if not defined FSM_DEFAULT_LANGUAGE set "FSM_DEFAULT_LANGUAGE=GERMAN"
call :require_value FSM_OWNER "Enter owner schema for FSM: " || exit /b 1
call :require_secret FSM_OWNER_PW "Enter password for %FSM_OWNER%" || exit /b 1
call :require_value FSM_SERVICE "Enter service name of the database or PDB: " || exit /b 1
call :run_sqlplus "%FSM_OWNER%" "%FSM_OWNER_PW%" "%FSM_SERVICE%" "%SCRIPT_DIR%install_scripts\install.sql" "%FSM_OWNER%" "%FSM_DEFAULT_LANGUAGE%"
exit /b %ERRORLEVEL%

:install_client
if not defined FSM_OWNER set "FSM_OWNER="
if not defined FSM_OWNER_PW set "FSM_OWNER_PW="
if not defined FSM_SERVICE set "FSM_SERVICE="
if not defined FSM_CLIENT set "FSM_CLIENT="
if not defined FSM_CLIENT_PW set "FSM_CLIENT_PW="
call :require_value FSM_OWNER "Enter owner schema for FSM: " || exit /b 1
call :require_secret FSM_OWNER_PW "Enter password for %FSM_OWNER%" || exit /b 1
call :require_value FSM_SERVICE "Enter service name for the database or PDB: " || exit /b 1
call :require_value FSM_CLIENT "Enter client schema name: " || exit /b 1
call :require_secret FSM_CLIENT_PW "Enter password for %FSM_CLIENT%" || exit /b 1
call :run_sqlplus "%FSM_OWNER%" "%FSM_OWNER_PW%" "%FSM_SERVICE%" "%SCRIPT_DIR%install_scripts\grant_client_access.sql" "%FSM_OWNER%" "%FSM_CLIENT%" || exit /b 1
call :run_sqlplus "%FSM_CLIENT%" "%FSM_CLIENT_PW%" "%FSM_SERVICE%" "%SCRIPT_DIR%install_scripts\create_client_synonyms.sql" "%FSM_OWNER%" "%FSM_CLIENT%"
exit /b %ERRORLEVEL%

:install_sample
if not defined FSM_SERVICE set "FSM_SERVICE="
if not defined FSM_SAMPLE_USER set "FSM_SAMPLE_USER="
if not defined FSM_SAMPLE_USER_PW set "FSM_SAMPLE_USER_PW="
if not defined FSM_APEX_USER set "FSM_APEX_USER="
if not defined FSM_APEX_USER_PW set "FSM_APEX_USER_PW="
if not defined FSM_APEX_WORKSPACE set "FSM_APEX_WORKSPACE="
if not defined FSM_APEX_APP_ID set "FSM_APEX_APP_ID="
call :require_value FSM_SAMPLE_USER "Enter schema that holds the sample business logic: " || exit /b 1
call :require_secret FSM_SAMPLE_USER_PW "Enter password for %FSM_SAMPLE_USER%" || exit /b 1
call :require_value FSM_SERVICE "Enter service name for the database or PDB: " || exit /b 1
call :require_value FSM_APEX_USER "Enter APEX schema that owns the APEX application: " || exit /b 1
call :require_secret FSM_APEX_USER_PW "Enter password for %FSM_APEX_USER%" || exit /b 1
call :require_value FSM_APEX_WORKSPACE "Enter name of APEX workspace: " || exit /b 1
call :require_value FSM_APEX_APP_ID "Enter the FSM application ID: " || exit /b 1
call :run_sqlplus "%FSM_SAMPLE_USER%" "%FSM_SAMPLE_USER_PW%" "%FSM_SERVICE%" "%SCRIPT_DIR%install_scripts\install_sample.sql" "%FSM_SAMPLE_USER%" "%FSM_APEX_USER%" || exit /b 1
call :run_sqlplus "%FSM_APEX_USER%" "%FSM_APEX_USER_PW%" "%FSM_SERVICE%" "%SCRIPT_DIR%install_scripts\install_sample_app.sql" "%FSM_SAMPLE_USER%" "%FSM_APEX_USER%" "%FSM_APEX_WORKSPACE%" "%FSM_APEX_APP_ID%"
exit /b %ERRORLEVEL%

:uninstall
if not defined FSM_OWNER set "FSM_OWNER="
if not defined FSM_OWNER_PW set "FSM_OWNER_PW="
if not defined FSM_SERVICE set "FSM_SERVICE="
call :require_value FSM_OWNER "Enter owner schema of FSM: " || exit /b 1
call :require_secret FSM_OWNER_PW "Enter password for %FSM_OWNER%" || exit /b 1
call :require_value FSM_SERVICE "Enter service name of the database or PDB: " || exit /b 1
call :run_sqlplus "%FSM_OWNER%" "%FSM_OWNER_PW%" "%FSM_SERVICE%" "%SCRIPT_DIR%install_scripts\uninstall.sql" "%FSM_OWNER%" "%FSM_OWNER%"
exit /b %ERRORLEVEL%

:uninstall_client
if not defined FSM_OWNER set "FSM_OWNER="
if not defined FSM_OWNER_PW set "FSM_OWNER_PW="
if not defined FSM_SERVICE set "FSM_SERVICE="
if not defined FSM_CLIENT set "FSM_CLIENT="
if not defined FSM_CLIENT_PW set "FSM_CLIENT_PW="
call :require_value FSM_OWNER "Enter owner schema of FSM: " || exit /b 1
call :require_secret FSM_OWNER_PW "Enter password for %FSM_OWNER%" || exit /b 1
call :require_value FSM_SERVICE "Enter service name for the database or PDB: " || exit /b 1
call :require_value FSM_CLIENT "Enter client schema name: " || exit /b 1
call :require_secret FSM_CLIENT_PW "Enter password for %FSM_CLIENT%" || exit /b 1
call :run_sqlplus "%FSM_OWNER%" "%FSM_OWNER_PW%" "%FSM_SERVICE%" "%SCRIPT_DIR%install_scripts\revoke_client_access.sql" "%FSM_OWNER%" "%FSM_CLIENT%" || exit /b 1
call :run_sqlplus "%FSM_CLIENT%" "%FSM_CLIENT_PW%" "%FSM_SERVICE%" "%SCRIPT_DIR%install_scripts\uninstall_client.sql" "%FSM_OWNER%" "%FSM_CLIENT%"
exit /b %ERRORLEVEL%

:uninstall_sample
if not defined FSM_SERVICE set "FSM_SERVICE="
if not defined FSM_SAMPLE_USER set "FSM_SAMPLE_USER="
if not defined FSM_SAMPLE_USER_PW set "FSM_SAMPLE_USER_PW="
if not defined FSM_APEX_USER set "FSM_APEX_USER="
if not defined FSM_APEX_USER_PW set "FSM_APEX_USER_PW="
if not defined FSM_APEX_WORKSPACE set "FSM_APEX_WORKSPACE="
if not defined FSM_APEX_APP_ID set "FSM_APEX_APP_ID="
call :require_value FSM_SAMPLE_USER "Enter schema that holds the sample business logic: " || exit /b 1
call :require_secret FSM_SAMPLE_USER_PW "Enter password for %FSM_SAMPLE_USER%" || exit /b 1
call :require_value FSM_SERVICE "Enter service name for the database or PDB: " || exit /b 1
call :require_value FSM_APEX_USER "Enter APEX schema that owns the APEX application: " || exit /b 1
call :require_secret FSM_APEX_USER_PW "Enter password for %FSM_APEX_USER%" || exit /b 1
call :require_value FSM_APEX_WORKSPACE "Enter name of APEX workspace: " || exit /b 1
call :require_value FSM_APEX_APP_ID "Enter the FSM application ID: " || exit /b 1
call :run_sqlplus "%FSM_APEX_USER%" "%FSM_APEX_USER_PW%" "%FSM_SERVICE%" "%SCRIPT_DIR%install_scripts\uninstall_sample_app.sql" "%FSM_SAMPLE_USER%" "%FSM_APEX_USER%" "%FSM_APEX_WORKSPACE%" "%FSM_APEX_APP_ID%" || exit /b 1
call :run_sqlplus "%FSM_SAMPLE_USER%" "%FSM_SAMPLE_USER_PW%" "%FSM_SERVICE%" "%SCRIPT_DIR%install_scripts\uninstall_sample.sql" "%FSM_SAMPLE_USER%" "%FSM_APEX_USER%"
exit /b %ERRORLEVEL%
