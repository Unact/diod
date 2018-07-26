CREATE TABLE reasons (
    local_id INTEGER PRIMARY KEY AUTOINCREMENT,
    local_ts DATETIME DEFAULT CURRENT_TIMESTAMP,
    id INTEGER,
    name TEXT
);
CREATE TABLE schedule_requests(
    local_id INTEGER PRIMARY KEY AUTOINCREMENT,
    local_ts DATETIME DEFAULT CURRENT_TIMESTAMP,
    id INTEGER,
    person INTEGER,
    person_name TEXT,
    ddateb DATETIME,
    ddatee DATETIME,
    comments TEXT,
    reason INTEGER,
    ddateb_future DATETIME,
    ddatee_future DATETIME
);
