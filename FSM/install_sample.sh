#!/bin/bash

echo -n "Enter schema that holds the sample business logic (must be FSM client or FSM owner) [ENTER] "
read OWNER
echo ${OWNER}

echo -n "Enter password for ${OWNER} [ENTER] "
read -s CLIENTPWD

echo -n "Enter service name for the database or PDB [ENTER] "
read SERVICE
echo ${SERVICE}

echo -n "Enter APEX schema that owns the APEX application [ENTER] "
read REMOTEOWNER
echo ${REMOTEOWNER}

echo -n "Enter password for ${REMOTEOWNER} [ENTER] "
read -s REMOTEPWD


echo -n "Enter name of APEX workspace [ENTER] "
read OWNER
echo ${APEX_WS}

echo -n "Enter the FSM application ID [ENTER] "
read OWNER
echo ${APEX_APP_ID}

NLS_LANG=GERMAN_GERMANY.AL32UTF8
export NLS_LANG

sqlplus ${OWNER}/"${CLIENTPWD}"@${SERVICE} @./install_scripts/install_sample.sql ${OWNER} ${REMOTEOWNER}

sqlplus ${REMOTEOWNER}/"${REMOTEPWD}"@${SERVICE} @./install_scripts/install_sample_app.sql ${OWNER} ${REMOTEOWNER} ${APEX_WS} ${APEX_APP_ID}
