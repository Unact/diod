CREATE TABLE person (
    id INTEGER PRIMARY KEY,
    name TEXT,
    ts DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE schedule_requests(
    id INTEGER PRIMARY KEY,
    ddateb DATETIME,
    ddatee DATETIME,
    ddateb_future DATETIME,
    ddatee_future DATETIME,
    person INTEGER,
    comments TEXT,
    ts DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE new_request (
    ddateb DATETIME,
    ddatee DATETIME,
    ddateb_future DATETIME,
    ddatee_future DATETIME,
    reason INTEGER,
    person INTEGER,
    comments TEXT
);
CREATE TABLE schedule_requests(
    id INTEGER PRIMARY KEY,
    ddateb DATETIME,
    ddatee DATETIME,
    ddateb_future DATETIME,
    ddatee_future DATETIME,
    person INTEGER,
    comments TEXT,
    ts DATETIME DEFAULT CURRENT_TIMESTAMP
);
