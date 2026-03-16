#!/bin/bash

echo -n "Enter owner schema of FSM [ENTER] "
read INSTALL_USER
echo ${INSTALL_USER}

echo -n "Enter password for ${INSTALL_USER} [ENTER] "
read -s INSTALL_PWD
echo

echo -n "Enter service name for the database or PDB [ENTER] "
read SERVICE
echo ${SERVICE}

echo -n "Enter client schema name [ENTER] "
read REMOTE_USER
echo ${REMOTE_USER}

echo -n "Enter password for ${REMOTE_USER} [ENTER] "
read -s REMOTE_PWD
echo

NLS_LANG=GERMAN_GERMANY.AL32UTF8
export NLS_LANG

sqlplus ${INSTALL_USER}/"${INSTALL_PWD}"@${SERVICE} @./install_scripts/revoke_client_access.sql ${INSTALL_USER} ${REMOTE_USER}

sqlplus ${REMOTE_USER}/"${REMOTE_PWD}"@${SERVICE} @./install_scripts/uninstall_client.sql ${INSTALL_USER} ${REMOTE_USER}
