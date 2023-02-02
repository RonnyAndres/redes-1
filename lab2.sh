
# ----------------------------------- Punto #1 -----------------------------------------------
# Instalamos el servicio 
apt-get update
apt-get install -y bind9
#\"si\"

# Configurar el archivo de configuración del servidor DNS
echo "zone \"pantoja.com.co.\" {
    type master;
    file \"/etc/bind/db.pantoja.com.co.zone\";
};

zone \"obando.edu.co.\" {
    type master;
    file \"/etc/bind/db.obando.edu.co.zone\";
};


// ----------- Resolucion Inversa de los dos dominios ----------------
zone \"0.16.172.in-addr.arpa\" {
    type master;
    file \"/etc/bind/db.pantojaobando.rev\";
};" > /etc/bind/named.conf.local 

# Crear el archivo de zona para PRIMER APELLIDO
touch /etc/bind/db.pantoja.com.co.zone 
echo "\$TTL 604800
@   IN  SOA pantoja.com.co. root.pantoja.com.co. (
                  2         ; Serial
             604800         ; Refresh
              86400         ; Retry
            2419200         ; Expire
             604800 )       ; Negative Cache TTL
;
@   IN  NS  pantoja.com.co.

@   	   IN  A   172.16.0.1
correo     IN  A   172.16.0.2
sistemas   IN  A   172.16.0.3
respaldo   IN  A   172.16.0.4
www        IN  A   172.16.0.3
www        IN  A   172.16.0.4" > /etc/bind/db.pantoja.com.co.zone 

# Crear el archivo de zona para SEGUNDO APELLIDO
touch /etc/bind/db.obando.edu.co.zone 
echo "\$TTL 604800
@   IN  SOA obando.edu.co. root.obando.edu.co. (
                  2         ; Serial
             604800         ; Refresh
              86400         ; Retry
            2419200         ; Expire
             604800 )       ; Negative Cache TTL
;
@   IN  NS  obando.edu.co.

@          IN  A   172.16.0.5
correo     IN  A   172.16.0.6
sistemas   IN  A   172.16.0.7
respaldo   IN  A   172.16.0.8
www        IN  A   172.16.0.7
www        IN  A   172.16.0.8" > /etc/bind/db.obando.edu.co.zone 

# ---------------------------------- Punto #2 --------------------------------
touch /etc/bind/db.pantojaobando.rev

echo "\$TTL 604800
@   IN  SOA pantoja.com.co. root.pantoja.com.co. (
                  3         ; Serial
             604800         ; Refresh
              86400         ; Retry
            2419200         ; Expire
             604800 )       ; Negative Cache TTL
;
@   IN  NS  pantoja.com.co.

1   IN  PTR pantoja.com.co.
2   IN  PTR correo.pantoja.com.co.
3   IN  PTR sistemas.pantoja.com.co.
4   IN  PTR respaldo.pantoja.com.co.
5   IN  PTR obando.edu.co.
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

sed -i '17s/nameserver 127.0.0.53/nameserver 172.16.0.1/' /etc/resolv.conf

service bind9 restart
service bind9 status
