# 1. /opt/jbcs-httpd24-2.4/httpd/conf/httpd.conf at end of file:

```

LimitRequestFieldSize 65535
LimitRequestLine 65535
ProxyIOBufferSize 65535

#
# Load config files from the config directory "/etc/httpd/conf.d".
#
IncludeOptional conf.d/*.conf

```

# 2. /opt/jbcs-httpd24-2.4/httpd/conf.d/ssl.conf

```

<VirtualHost _default_:443>
ServerName  sso.pietersmalan.com

LimitRequestFieldSize 655360


ProxyRequests Off
ProxyPreserveHost On
<Proxy *>
AddDefaultCharset Off
Order deny,allow
Allow from all
</Proxy>
ProxyPass / http://sso.pietersmalan.com:6666/ responsefieldsize=655360 iobuffersize=655360
ProxyPassReverse / http://sso.pietersmalan.com:6666/

</VirtualHost>

```

# 3. /opt/jbcs-httpd24-2.4/httpd/conf.d/mod_proxy_cluster.conf

```

# mod_proxy_balancer should be disabled when mod_cluster is used
LoadModule proxy_cluster_module modules/mod_proxy_cluster.so
LoadModule cluster_slotmem_module modules/mod_cluster_slotmem.so
LoadModule manager_module modules/mod_manager.so
LoadModule advertise_module modules/mod_advertise.so

MemManagerFile cache/mod_cluster

<IfModule manager_module>
Listen *:6666
<VirtualHost *:6666>
    LimitRequestFieldSize 65536
    LimitRequestLine 65536
    DirectoryIndex disabled
    <Directory />
    # add ip of JBoss nodes to join this proxy here
    Require ip 10.0.1.169
    </Directory>
    ServerAdvertise on
    EnableMCPMReceive
    <Location /mod_cluster_manager>
    SetHandler mod_cluster-manager
    # add ip of clients allowed to access mod_cluster-manager
    Require ip 10.0.1.169
</Location>
</VirtualHost>
</IfModule>

```

# 4. /home/sso/rh-sso-7.6/domain/configuration/domain.xml


domain.xml:504:                    <http-listener name="default" socket-binding="http" redirect-socket="https" enable-http2="true" max-header-size="65536" />
domain.xml:505:                    <https-listener name="https" socket-binding="https" security-realm="ApplicationRealm" enable-http2="true" max-header-size="65536" />
domain.xml:1048:                    <http-listener name="default" socket-binding="http" redirect-socket="https" enable-http2="true" max-header-size="65536" />
domain.xml:1049:                    <https-listener name="https" socket-binding="https" security-realm="ApplicationRealm" enable-http2="true" max-header-size="65536" />
domain.xml:1106:                    <http-listener name="default" socket-binding="http" redirect-socket="https" enable-http2="true" max-header-size="65536" />
domain.xml:1107:                    <http-listener name="management" socket-binding="mcmp-management" enable-http2="true" max-header-size="65536" />

In domain.xml:31: add   <property name="org.apache.coyote.http11.Http11Protocol.MAX_HEADER_SIZE" value="65535"/> as in:

```

    <system-properties>
            <property name="java.net.preferIPv4Stack" value="true"/>
            <property name="org.apache.coyote.http11.Http11Protocol.MAX_HEADER_SIZE" value="65535"/>
            <property name="org.apache.coyote.ajp.MAX_PACKET_SIZE" value="65536"/>
    </system-properties>

```
