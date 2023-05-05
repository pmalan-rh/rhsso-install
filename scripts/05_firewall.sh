#!/bin/bash
firewall-cmd --zone=public --permanent --add-service=postgresql
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=443/tcp --permanent
firewall-cmd --add-port=6666/tcp --permanent
firewall-cmd --reload


