#!/bin/bash
cd /opt/
unzip /tmp/jbcs-httpd24-httpd-2.4.51-RHEL8-x86_64.zip
cd /opt/jbcs-httpd24-2.4/httpd/
export HTTPD_HOME=/opt/jbcs-httpd24-2.4/httpd/
sh .postinstall
sh .postinstall.systemd

dnf install -y selinux-policy-devel
sh .postinstall.selinux
cd $HTTPD_HOME/selinux
make -f /usr/share/selinux/devel/Makefile
semodule -i jdbc-httpd24-httpd.pp
restorecon -r $HTTPD_HOME
semanage port -a -t http_port_t -p tcp 6666
semanage port -a -t http_port_t -p udp 23364

systemctl enable jbcs-httpd24-httpd.service
systemctl stop jbcs-httpd24-httpd.service
systemctl start jbcs-httpd24-httpd.service
systemctl status jbcs-httpd24-httpd.service

ps -eZ | grep httpd | head -n1
