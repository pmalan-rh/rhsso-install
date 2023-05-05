01_users.sh
02_install_apache.sh
03_install_rpms.sh
su -c ./04_install_rh-sso.sh sso
05_firewall.sh
06_postgres_svc.sh
su -c ./07_postgres_db.sh postgres
08_mod_proxy_cluster.sh
