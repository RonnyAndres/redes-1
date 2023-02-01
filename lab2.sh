
# ----------------------------------- Punto #1 -----------------------------------------------
# Instalamos el servicio 
apt-get update
apt-get install -y bind9
#\"si\"

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
zone \"1.168.192.in-addr.arpa\" {
    type master;
    file \"/etc/bind/db.pantojaobando.rev\";
};
zone \"0.0.172.in-addr.arpa\" {
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
@   IN  A   192.168.1.1

ns1        IN  A   192.168.1.1
correo     IN  A   192.168.1.2
sistemas   IN  A   192.168.1.3
respaldo   IN  A   192.168.1.4
www        IN  A   192.168.1.3
www        IN  A   192.168.1.4" > /etc/bind/db.pantoja.com.co.zone 

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
@   IN  A   192.168.1.1

ns1        IN  A   192.168.1.5
correo     IN  A   192.168.1.6
sistemas   IN  A   192.168.1.7
respaldo   IN  A   192.168.1.8
www        IN  A   192.168.1.7
www        IN  A   192.168.1.8" > /etc/bind/db.obando.edu.co.zone 

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



sed -i '17s/nameserver 127.0.0.53/nameserver 192.168.1.10/' /etc/resolv.conf

service bind9 restart
service bind9 status
