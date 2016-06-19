@echo off
set nls_lang=GERMAN_GERMANY.AL32UTF8
set /p Credentials= Enter a connect string without 'as sysdba' for SYS:
set /p InstallUser= Enter username of the software owner:

sqlplus %Credentials% as sysdba @uninstall %Credentials% %InstallUser%

pause
