
# ----------------------------------- Punto #1 -----------------------------------------------
# Instalamos el servicio 
apt-get update
apt-get install -y bind9
#\"si\"
echo "network:
  ethernets:
    enp0s3:
      dhcp4: true
    enp0s8:
      addresses:
      - 172.16.0.10/24
      gateway4: 172.16.0.1
      nameservers:
        addresses:
        - 8.8.8.8
        - 8.8.4.4
  version: 2" > /etc/netplan/00-installer-config.yaml
# Configurar el archivo de configuración del servidor DNS
echo "zone \"pantoja.com.co\" {
    type master;
    file \"/etc/bind/db.pantoja.com.co.zone\";
};

zone \"obando.edu.co\" {
    type master;
    file \"/etc/bind/db.obando.edu.co.zone\";
};
zone \"localhost\" {
    type master;
    file \"/etc/bind/db.localhost.zone\";
};

// ----------- Resolucion Inversa de los dos dominios ----------------
zone \"0.16.172.in-addr.arpa\" {
    type master;
    file \"/etc/bind/db.pantojaobando.rev\";
};
zone \"0.0.127.in-addr.arpa\" {
    type master;
    file \"/etc/bind/db.127\";
};


" > /etc/bind/named.conf.default-zones 

# Crear el archivo de zona para PRIMER APELLIDO
touch /etc/bind/db.pantoja.com.co.zone 
echo "\$TTL 604800
@   IN  SOA ns1.pantoja.com.co. admin.pantoja.com.co. (
                  2         ; Serial
             604800         ; Refresh
              86400         ; Retry
            2419200         ; Expire
             604800 )       ; Negative Cache TTL
;
@   IN  NS  ns1.pantoja.com.co.
@   IN  A   172.16.0.1

ns1        IN  A   172.16.0.1
correo     IN  A   172.16.0.2
sistemas   IN  A   172.16.0.3
respaldo   IN  A   172.16.0.4
www        IN  A   172.16.0.3
www        IN  A   172.16.0.4" > /etc/bind/db.pantoja.com.co.zone 

# Crear el archivo de zona para SEGUNDO APELLIDO
touch /etc/bind/db.obando.edu.co.zone 
echo "\$TTL 604800
@   IN  SOA ns1.obando.edu.co. admin.obando.edu.co. (
                  2         ; Serial
             604800         ; Refresh
              86400         ; Retry
            2419200         ; Expire
             604800 )       ; Negative Cache TTL
;
@   IN  NS  ns1.obando.edu.co.
@   IN  A   172.16.0.1

ns1        IN  A   172.16.0.5
correo     IN  A   172.16.0.6
sistemas   IN  A   172.16.0.7
respaldo   IN  A   172.16.0.8
www        IN  A   172.16.0.7
www        IN  A   172.16.0.8" > /etc/bind/db.obando.edu.co.zone 

# Crear el archivo de LOCALHOST

echo "\$TTL 604800
@   IN  SOA localhost. admin.localhost. (
                  2         ; Serial
             604800         ; Refresh
              86400         ; Retry
            2419200         ; Expire
             604800 )       ; Negative Cache TTL
;
@   IN  NS  localhost.
@   IN  A   127.0.0.1

localhost.    IN  A   127.0.0.1" > /etc/bind/db.localhost.zone

# Creamos el archivo inverso
echo ";
; BIND reverse data file for local loopback interface
;
\$TTL	604800
@	IN	SOA	localhost. root.localhost. (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	localhost.
1	IN	PTR	localhost." > /etc/bin/db.127

# ---------------------------------- Punto #2 --------------------------------
touch /etc/bind/db.pantojaobando.rev

echo "\$TTL 604800
@   IN  SOA ns1.pantoja.com.co. admin.pantoja.com.co. (
                  2         ; Serial
             604800         ; Refresh
              86400         ; Retry
            2419200         ; Expire
             604800 )       ; Negative Cache TTL
;
@   IN  NS  ns1.pantoja.com.co.

1   IN  PTR ns1.pantoja.com.co.
2   IN  PTR correo.pantoja.com.co.
3   IN  PTR sistemas.pantoja.com.co.
4   IN  PTR respaldo.pantoja.com.co.
5   IN  PTR ns1.obando.edu.co.
6   IN  PTR correo.obando.edu.co.
7   IN  PTR sistemas.obando.edu.co.
8   IN  PTR respaldo.obando.edu.co." > /etc/bind/db.pantojaobando.rev

echo "options {
        directory \"/var/cache/bind\";
        forwarders {
                8.8.8.8;
                8.8.4.4;
        };
        dnssec-validation auto;
        auth-nxdomain no;
        listen-on-v6 { any; };
};" > /etc/bind/named.conf.options

sed -i '17s/nameserver 127.0.0.53/nameserver 172.16.0.10/' /etc/resolv.conf

service bind9 restart
service bind9 status
