#!/bin/bash
echo -n "Enter owner schema for FSM [ENTER] "
read OWNER
echo ${OWNER}

echo -n "Enter password for ${OWNER} [ENTER] "
read PWD

echo -n "Enter service name of the database or PDB [ENTER] "
read SERVICE
echo ${SERVICE}

NLS_LANG=GERMAN_GERMANY.AL32UTF8
export NLS_LANG

sqlplus ${OWNER}/"${PWD}"@${SERVICE} @./install_scripts/install ${OWNER} foo
