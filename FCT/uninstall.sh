#!/bin/bash
echo -n "Enter a connect string without 'as sysdba' for SYS: [ENTER] "
read SYSPWD
echo ${SYSPWD}

echo -n "Enter username where the software shall be installed at: [ENTER] "
read USER
echo ${USER}

echo -n "Enter default Oracle language name for messages: [ENTER] "
read DEFAULT_LANGUAGE
echo ${DEFAULT_LANGUAGE}

echo -n "Shall the sample applications be installed (Y|N)?: [ENTER] "
read WITH_SAMPLES
echo ${WITH_SAMPLES}

NLS_LANG=GERMAN_GERMANY.AL32UTF8
export NLS_LANG
sqlplus /nolog<<EOF
connect ${SYSPWD} as sysdba 
@install ${USER} ${DEFAULT_LANGUAGE} ${WITH_SAMPLES}
pause
EOF

