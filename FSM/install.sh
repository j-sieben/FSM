#!/bin/bash
echo -n "Enter a connect string without 'as sysdba' for SYS: [ENTER] "
read SYSPWD
echo ${SYSPWD}

echo -n "Enter username where the software shall be installed at: [ENTER] "
read USER
echo ${USER}

echo -n "Enter default language to install (GERMAN|AMERICAN): [ENTER] "
read LANGUAGE
echo ${LANGUAGE}

NLS_LANG=GERMAN_GERMANY.AL32UTF8
export NLS_LANG
sqlplus /nolog<<EOF
connect ${SYSPWD} as sysdba 
@fsm_install ${USER} ${LANGUAGE}
pause
EOF

