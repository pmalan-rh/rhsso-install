#!/bin/bash


cd ~
rm -Rf rh-sso-7.6
killall java

unzip /tmp/rh-sso-7.6.0-server-dist.zip 
export PATH=$PATH:~/rh-sso-7.6/bin
mkdir ~/tmp
export _JAVA_OPTIONS='-Djava.io.tmpdir=/home/sso/tmp'

jboss-cli.sh <<EOF
patch apply /tmp/rh-sso-7.6.2-patch.zip
quit
EOF

jboss-cli.sh <<EOF
patch apply /tmp/rhsso-2361.zip
quit
EOF

#wget https://jdbc.postgresql.org/download/postgresql-42.6.0.jar


jboss-cli.sh <<EOF
module add --name=org.postgres --slot=main --resources=/tmp/postgresql-42.6.0.jar --dependencies=javax.api,javax.transaction.api
exit
EOF


echo "Starting domain"
nohup domain.sh>/dev/null 2>&1 &

while true #check if the port is ready
do  
    sleep 1
    if netstat -an | grep 9990 | grep LISTEN
        then
        break
    fi
    echo .
done
echo Waiting for server to start
while true  #check if the server start success
do  
    if jboss-cli.sh --connect command='/host=master/server-config=server-one:read-attribute(name=status)' | grep STARTED
    then
        break
    fi
    echo .
    sleep 1
done


jboss-cli.sh <<EOF
connect
#/host=master/server-config=server-one:start(blocking=true)
/profile=auth-server-clustered/subsystem=datasources/jdbc-driver=postgres:add(driver-name="postgres",driver-module-name="org.postgres",driver-class-name=org.postgresql.Driver)
data-source remove --name=KeycloakDS --profile=auth-server-clustered
data-source add \
   --name=KeycloakDS --jndi-name=java:jboss/datasources/KeycloakDS \
   --driver-name=postgres --connection-url=jdbc:postgresql://10.0.1.189/keycloak \
   --user-name=keycloak --password=keycloak --max-pool-size=20 \
   --profile=auth-server-clustered
data-source enable --name=KeycloakDS --profile=auth-server-clustered
/socket-binding-group=ha-sockets/remote-destination-outbound-socket-binding=proxy1:add(host=10.0.1.189,port=6666)
/profile=auth-server-clustered/subsystem=modcluster/proxy=default:write-attribute(name=proxies,value=[proxy1])
/profile=auth-server-clustered/subsystem=keycloak-server/spi=hostname/provider=default:write-attribute(name=properties.frontendUrl,value="https://sso.pietersmalan.com/auth")
/host=master/server-config=server-two:add(group=auth-server-group,auto-start=true,socket-binding-port-offset=160)
/host=master/server-config=server-three:add(group=auth-server-group,auto-start=true,socket-binding-port-offset=170)
/server-group=auth-server-group:stop-servers(blocking=true)
/host=master/server-config=load-balancer:stop(blocking=true)
/host=master/server-config=load-balancer:remove()
shutdown --host=master
exit
EOF

killall java 

echo "Setting up standalone server"
nohup standalone.sh>/dev/null 2>&1 &

while true #check if the port is ready
do
    sleep 1
    if netstat -an | grep 9990 | grep LISTEN
        then
        break
    fi
    echo .
done
echo Waiting for server to start
while true  #check if the server start success
do
    if jboss-cli.sh --connect command=':read-attribute(name=server-state)' | grep running
    then
        break
    fi
    echo .
    sleep 1
done

jboss-cli.sh <<EOF
module add --name=org.postgres --slot=main --resources=~/postgresql-42.6.0.jar --dependencies=javax.api,javax.transaction.api
exit
EOF


jboss-cli.sh <<EOF
connect
/subsystem=datasources/jdbc-driver=postgres:add(driver-name="postgres",driver-module-name="org.postgres",driver-class-name=org.postgresql.Driver)
data-source remove --name=KeycloakDS 
data-source add \
   --name=KeycloakDS --jndi-name=java:jboss/datasources/KeycloakDS \
   --driver-name=postgres --connection-url=jdbc:postgresql://10.0.1.189/keycloak \
   --user-name=keycloak --password=keycloak --max-pool-size=20 
data-source enable --name=KeycloakDS 
shutdown 
exit
EOF

killall java

mkdir ~/rh-sso-7.6/domain/servers/server-one/configuration
add-user-keycloak.sh --sc ~/rh-sso-7.6/domain/servers/server-one/configuration -r master -u admin -p admin
