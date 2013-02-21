DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS roles;
DROP TABLE IF EXISTS user_roles;

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    active CHAR(1) NOT NULL,
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    password_expires TIMESTAMP,
    name TEXT NOT NULL,
    email_address TEXT NOT NULL,
    phone_number TEXT,
    mail_address TEXT
);

CREATE TABLE roles (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE user_roles (
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE,
    role_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE,
    PRIMARY KEY (user_id, role_id)
);

INSERT INTO users (username, active, name, email_address, password) VALUES (
    'admin', 'Y', 'Administrator', 'admin@myapp.org', 'dummy'
);
INSERT INTO roles (name) VALUES ('admin');
INSERT INTO roles (name) VALUES ('can_edit');
INSERT INTO user_roles (user_id, role_id) VALUES (
    (SELECT id FROM users WHERE username = 'admin'),
    (SELECT id FROM roles WHERE name     = 'admin')
);
