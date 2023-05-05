# rhsso-install
Red Hat Single Sign install on RHEL8

With Registered Red Hat account download:

## Download required software

Download: https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=104539
          https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=105250
          https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=105144
          https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=104829 
          
Download latest JDBC driver for Postgress, at time of writing :  https://jdbc.postgresql.org/download/postgresql-42.6.0.jar

## Stage Software

Copy zip files, and jar file to /tmp on target machine.

## Prepare for installation

Replace the host name to suite your environment:

grep -rlZ 'sso.pietersmalan.com' . | xargs -0 sed -i.bak 's/sso.pietersmalan.com/ss.yourdomain.com/g'
grep -rlZ '10.0.1.189' . | xargs -0 sed -i.bak 's/10.0.1.189/192.168.89.12/g'

## Run Installation script
scripts/install.sh

