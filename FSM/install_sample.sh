#!/bin/bash

echo -n "Enter schema that holds the sample business logic (must be FSM client or FSM owner) [ENTER] "
read INSTALL_USER
echo ${INSTALL_USER}

echo -n "Enter password for ${INSTALL_USER} [ENTER] "
read -s INSTALL_PWD
echo

echo -n "Enter service name for the database or PDB [ENTER] "
read SERVICE
echo ${SERVICE}

echo -n "Enter APEX schema that owns the APEX application [ENTER] "
read REMOTE_USER
echo ${REMOTE_USER}

echo -n "Enter password for ${REMOTE_USER} [ENTER] "
read -s REMOTE_PWD
echo

echo -n "Enter name of APEX workspace [ENTER] "
read APEX_WS
echo ${APEX_WS}

echo -n "Enter the FSM application ID [ENTER] "
read APEX_APP_ID
echo ${APEX_APP_ID}

NLS_LANG=GERMAN_GERMANY.AL32UTF8
export NLS_LANG

sqlplus ${INSTALL_USER}/"${INSTALL_PWD}"@${SERVICE} @./install_scripts/install_sample.sql ${INSTALL_USER} ${REMOTE_USER}

sqlplus ${REMOTE_USER}/"${REMOTE_PWD}"@${SERVICE} @./install_scripts/install_sample_app.sql ${INSTALL_USER} ${REMOTE_USER} ${APEX_WS} ${APEX_APP_ID}
