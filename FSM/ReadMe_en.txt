The batch files or shell scripts install FSM in three different forms:

1. INSTALL.BAT/SH: Core functionality.
   This must be installed first. It is recommended to use a dedicated user for this,
   e.g. UTILS, and to grant a client access to the schemas that want to use FSM afterwards.
   Alternatively, this client can also be omitted if only one schema is to be equipped with FSM.

2. INSTALL_CLIENT.BAT/SH: Client access
   This script sets up access to a FSM installation in a different schema.
   All necessary permissions are granted and appropriate synonyms are created in the client schema.
   
3. INSTALL_APEX.BAT/SH: Sample application
   This script sets up the sample application for FSM. The installation
   includes the setup of all necessary permissions and the creation of local synonyms. 
   The application requires two other tools:
   - UTL_TEXT: This tool provides text functions, e.g. a code generator.
   - UTL_APEX: This tool provides APEX related functions.
   These tools have to be installed before the installation of the sample application
   can be executed successfully.
   
All scripts interactively request the required parameters. Follow the instructions of the scripts.

Linux remarks:
set ORACLE_SID, PATH and ORACLE_HOME:

for information, see /etc/oratab.

ORACLE_HOME=<Info from Oratab-File>
PATH=$ORACLE_HOME/bin:$PATH
ORACLE_SID=<Info from Oratab-File>
export ORACLE_HOME
export PATH
export ORACLE_SID

Should install.sh don’t run:
chmod +x ./install.sh