CREATE TABLE events (
    idevents INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    host TEXT NOT NULL,
    service TEXT,
    category TEXT,
    parameters TEXT,
    priority TEXT,
    message TEXT NOT NULL,
    monitoringstatus TEXT NOT NULL,
    created TIMESTAMP NOT NULL,
    fk_idtickets INTEGER REFERENCES tickets (idtickets));
    
CREATE TABLE tickets (
    idtickets INTEGER PRIMARY KEY AUTOINCREMENT,
    ticketnumber TEXT,
    ticketstatus TEXT,
    created TIMESTAMP NOT NULL,
    modified TIMESTAMP);