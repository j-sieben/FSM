---
tags:
  - fsm
  - start
---

# FSM-Dokumentation

Geschäftsobjekte besitzen häufig einen geregelten Lebenszyklus: Sie werden angelegt, geprüft, bearbeitet und abgeschlossen. Welche Aktion zulässig ist, hängt dabei von ihrer aktuellen Phase ab. Das FSM-Framework bildet solche Abläufe als endliche Zustandsautomaten ab und sorgt dafür, dass Statusänderungen nach einheitlichen Regeln ausgeführt, gespeichert und protokolliert werden.

Das Framework verbindet ein zentral verwaltetes [[Glossar/Metadatenmodell|Metadatenmodell]] mit fachlichen PL/SQL-Implementierungen. Ein gemeinsamer Oracle-Objekttyp stellt die Daten und Methoden bereit, die jede FSM benötigt. Davon abgeleitete Typen ergänzen ihre fachlichen Daten und Aktionen. Der Laufzeitkern kann sie dadurch alle über dieselben Methoden ansprechen.

## Orientierung

- [[00_Start/Einführung-in-Finite-State-Machines|Einführung in Finite State Machines]] – Idee, Nutzen und Umsetzung in Oracle PL/SQL
- [[00_Start/Lesereihenfolge|Lesereihenfolge]] – geeignete Einstiege je Zielgruppe
- [[01_Architektur/Architekturüberblick|Architekturüberblick]] – Komponenten und Verantwortlichkeiten
- [[01_Architektur/Laufzeit-und-Lifecycle|Laufzeit und Lifecycle]] – zeitliche Reihenfolge eines Statuswechsels
- [[02_Funktionen/Instanzen-erstellen-und-laden|Instanzen erstellen und laden]] – Konstruktoren und Initialisierung
- [[02_Funktionen/Ereignisse-und-Statuswechsel|Ereignisse und Statuswechsel]] – Ereignisprüfung, Handler und Autoevents
- [[03_FSM-verwenden/FSM-im-eigenen-Projekt-verwenden|FSM im eigenen Projekt verwenden]] – Integration in fachliche Packages und Tabellen
- [[04_Betrieb/Installation-und-generierte-Objekte|Installation und generierte Objekte]] – Installationsreihenfolge
- [[Glossar/Glossar|Glossar]] – zentrale Begriffe

## Dokumentationsebenen

| Ebene | Zweck |
| --- | --- |
| Dieser Vault | Architektur, Abläufe, Verantwortlichkeiten und Regeln für die Nutzung in eigenen Projekten |
| `Doc/index.html` | generierte Natural-Docs-Referenz der Packages, Typen und Tabellen |
| `FSM/core` | ausführbarer Ist-Stand des Frameworks |
| `FSM/sample_app` | Referenzimplementierung einer konkreten FSM |

## Zentrale Zusicherung

Ein Aufruf von `FSM.SET_STATUS` verarbeitet den Statuswechsel synchron. Nach dem Persistieren und Loggen werden konfigurierte [[Glossar/Automatisches Ereignis|automatische Ereignisse]] rekursiv ausgeführt. Der Aufruf kehrt mit einer stabilisierten oder terminalen Instanz zurück.
