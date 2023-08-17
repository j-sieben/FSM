Die Batch-Dateien bzw. Shell-Skripte installieren FSM in drei unterschiedlichen Ausprägungen:

1. INSTALL.BAT/SH: Core-Funktionalität.
   Diese muss als erstes installiert werden. Empfohlen wird, einen dedizierten Benutzer hierfür 
   zu verwenden, z.B. UTILS, und an die Schemata, die FSM anschließend nutzen möchten, einen
   Zugriff über einen Client zu gewähren.
   Alternativ kann aber auch auf diesen Client verzichtet werden, falls nur ein Schema mit FSM
   ausgestattet werden soll.

2. INSTALL_CLIENT.BAT/SH: Client-Zugriff
   Dieses Skript richtet den Zugriff auf eine FSM-Installation in einem anderen Schema ein.
   Es werden alle erforderlichen Rechte erteilt und entsprechende Synonyme im Client-Schema erstellt.
   
3. INSTALL_SAMPLE.BAT/SH: Beispielanwendung
   Dieses Skript richtet die Beispielanwendung für FSM ein.
   Die Administrationsanwendung setzt zwei weitere Tools voraus:
   - UTL_TEXT: Dieses Tool stellt Textfunktionen zur Verfügung, z.B. einen Code-Generator
   - UTL_APEX: Dieses Tool stellt APEX-bezogene Funktionen zur Verfügung
   Diese Tools müssen vorab installiert werden, bevor die Installation der Beispielanwendung
   erfolgreich ausgeführt werden kann.
   
Alle Skripte erfragen interaktiv die erforderlichen Parameter. Folgen Sie den Anweisungen der Skripte.

Anmerkungen für Linux:
ORACLE_SID, PATH und ORACLE_HOME auf Unix setzen:

Infos hierzu immer in /etc/oratab.

ORACLE_HOME=<Info aus Oratab-File>
PATH=$ORACLE_HOME/bin:$PATH
ORACLE_SID=<Info aus Oratab-File>
export ORACLE_HOME
export PATH
export ORACLE_SID

Und natürlich nie vergessen, falls install.sh nicht ausführbar sein sollte:
chmod +x ./install.sh