#!/bin/bash
echo -n "Enter a connect string without 'as sysdba' for SYS: [ENTER] "
read SYSPWD
echo ${SYSPWD}

echo -n "Enter username where the software shall be installed at: [ENTER] "
read USER
echo ${USER}

echo -n "Enter tablespace for user ${USER}: [ENTER] "
read TABLESPACE
echo ${TABLESPACE}
NLS_LANG=GERMAN_GERMANY.AL32UTF8
export NLS_LANG
sqlplus /nolog<<EOF
connect ${SYSPWD} as sysdba 
@pit_install ${USER} ${TABLESPACE}
pause
EOF

