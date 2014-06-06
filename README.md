MoTMa
=====

Monitoring Ticketing Manager

Schnittstellen Manager zwischen Monitoring- und Service Desk Tools.

Funktionsbeschreibung: 
- Events von Monitoring Tools entgegennehmen 
- Event in lokaler DB zwischenspeichern 
- Event Priorisierung (Critical -> Minor, Critical, Fatal) 
- Service Desk Tool via Webservice - Schnittstelle aufrufen und Ticket generierenVerantwortung über Erreichbarkeit und Eventablieferung liegt bei MotMa 
- Ticket Nummer entgegennehmen und Event in lokaler DB aktualisieren 
- Ticket Nummer an Monitoring Tool weiterleiten (bei Bedarf) 
- Acknowledge (setzen, löschen) an Monitoring Tool senden (bei Bedarf) 
- Gleiche Events (wenn kein Ticket-Nr oder Ticket Status offen) zusammenfassen 
- Ticket in Service Desk aktualisieren 
- Regelmässig Ticket Status in Service Desk Tool abfragen und Event Eintrag nachführen 
- Auswertung und Verwaltung der zentralen Events

Bestehend: 
- Zentrales Management Module 
    - Als Service laufend 
    - Lokale DB mit SQLight 
    - Logik der Event - Behandlung 
     Auswertung und Management Funktionen der Events 
- Schnittstellen Module zu Monitoring Tools
    - Event entgegennehmen 
    - Update Monitoring Tool mit Ticket Nummer 
    - Acknowledge im Monitoring Tool setzen / löschen 
- Schnittstellen Module zu Service Desk Tools (Start mit Nagios) 
    - Webservice abfragen für Ticket erstellen, Ticket abfragen, Ticket aktualisieren

Unterstützte Monitoring Tools
- GroundWork, OMD, Nagios
- Service Center Operations Manager
- WhatsUP Gold

Weitere unterstützte Service Desk Tools
- OTRS
- Ky2Help 
- BMC Service Desk Express

Projektstart: Mai 2014

Projektplan 
- Design und Entwicklung zentrales Module und DB Struktur 
- Schnittstellen zu Nagios (Event ententgegen nehmen, Acknowlege setzt/löschen, Update Nagios mit Ticket Information) 
- Schnittstelle zu BMC SDE via Webservice Schnittstelle 
- Management und Auswertungen der Event Informationen 
- Entwicklung weiterer Schnittstellen zu Monitoring Tools (SCOM, WhatsUp Gold etc.) 
- Entwicklung weiterer Schnittstellen zu Service Desk Tools (ky2Help, OTRS etc.)

English translation will follow later
