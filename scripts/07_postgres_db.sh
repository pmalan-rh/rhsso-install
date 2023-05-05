#!/bin/bash
cd ~

psql <<EOF
ALTER SYSTEM SET listen_addresses TO '*';
SELECT pg_reload_conf();
drop database keycloak;
create database keycloak with encoding 'UTF8';
create user keycloak with encrypted password 'keycloak';
grant all privileges on database keycloak to keycloak;
\q
EOF

