#!/bin/bash
groupadd sso
adduser sso -G sso -g wheel
echo "sso"|passwd --stdin sso
groupadd -g 48 -r apache
useradd -c "Apache" -u 48 -g apache -s /sbin/nologin -r apache
