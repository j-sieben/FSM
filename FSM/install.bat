@echo off
set nls_lang=GERMAN_GERMANY.AL32UTF8
set /p Credentials= Enter a connect string without 'as sysdba' for SYS:
set /p InstallUser= Enter username where the software shall be installed at:
set /p DefaultLanguage= Enter default language as Oracle language name (AMERICAN):
set /p WithSamples= Do you want to install a sample aplication? (Y|N):

sqlplus %Credentials% as sysdba @install %InstallUser% %DefaultLanguage% %WithSamples%

pause
