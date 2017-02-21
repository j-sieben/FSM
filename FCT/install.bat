@echo off
rem set nls_lang=GERMAN_GERMANY.AL32UTF8
set /p Credentials= Enter a connect string without 'as sysdba' for SYS:
set /p InstallUser= Enter username where the software shall be installed at:
set /p Tablespace= Enter tablespace for user %InstallUser%:

sqlplus %Credentials% as sysdba @install %InstallUser% %Tablespace%

pause
