#!/bin/bash

\cp mod_proxy_cluster.conf /opt/jbcs-httpd24-2.4/httpd/conf.d
\cp ssl.conf /opt/jbcs-httpd24-2.4/httpd/conf.d/ssl.conf
systemctl restart jbcs-httpd24-httpd.service 
