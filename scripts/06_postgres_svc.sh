#!/bin/bash

/usr/bin/postgresql-setup --initdb
echo "host all all 0.0.0.0/0  md5" >> /var/lib/pgsql/data/pg_hba.conf
systemctl enable postgresql
systemctl stop postgresql
systemctl start postgresql

