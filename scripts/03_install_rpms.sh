#!/bin/bash
subscription-manager repos --enable=rhel-8-for-x86_64-baseos-rpms --enable=rhel-8-for-x86_64-appstream-rpms
dnf install java-11-openjdk @postgresql

