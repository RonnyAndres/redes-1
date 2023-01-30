
# ----------------------------------- Punto #1 -----------------------------------------------
# Instalamos el servicio 
apt-get update
apt-get install -y bind9
#\"si\"

# Configurar el archivo de configuración del servidor DNS
sudo bash -c "cat > /etc/bind/named.conf.default-zone << EOL
zone \"pantoja.com.co\" {
    type master;
    file \"/etc/bind/db.pantoja.com.co.zone\";
};

zone \"obando.edu.co\" {
    type master;
    file \"/etc/bind/db.obando.edu.co.zone\";
};
EOL"

# Crear el archivo de zona para PRIMER APELLIDO
sudo bash -c "cat > /etc/bind/db.pantoja.com.co << EOL
\$TTL\ 604800
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
EOL"

# Crear el archivo de zona para SEGUNDO APELLIDO
sudo bash -c "cat > /etc/bind/db.obando.edu.co.zone << EOL
\$TTL\ 604800
@   IN  SOA ns1.obando.edu.co. admin.obando.edu.co. (
                  2         ; Serial
             604800         ; Refresh
              86400         ; Retry
            2419200         ; Expire
             604800 )       ; Negative Cache TTL
;
@   IN  NS  ns1.obando.edu.co.
@   IN  A   172.16.5.1

1 IN  PTR ns1.pantoja.com.co.
2 IN  PTR correo.pantoja.com.co.
3 IN  PTR sistemas.pantoja.com.co.
4 IN  PTR respaldo.pantoja.com.co.
EOL"

# ----------------------------------- Punto #2 -----------------------------------------------
# Crear el archivo de zona INVERSO para PRIMER APELLIDO
sudo bash -c "cat > /etc/bind/db.pantoja.com.co.rev << EOL
\$TTL\ 604800
@   IN  SOA ns1.pantoja.com.co. admin.pantoja.com.co. (
                  2         ; Serial
             604800         ; Refresh
              86400         ; Retry
            2419200         ; Expire
             604800 )       ; Negative Cache TTL
;
@   IN  NS  ns1.pantoja.com.co.
@   IN  A   192.168.1.1

1 IN  PTR ns1.pantoja.com.co.
2 IN  PTR correo.pantoja.com.co.
3 IN  PTR sistemas.pantoja.com.co.
4 IN  PTR respaldo.pantoja.com.co.

EOL"

# Crear el archivo de zona INVERSO para SEGUNDO APELLIDO
sudo bash -c "cat > /etc/bind/db.obando.edu.co.rev << EOL
\$TTL\ 604800
@   IN  SOA ns1.pantoja.com.co. admin.pantoja.com.co. (
                  2         ; Serial
             604800         ; Refresh
              86400         ; Retry
            2419200         ; Expire
             604800 )       ; Negative Cache TTL
;
@   IN  NS  ns1.obando.edu.co.
@   IN  A   192.168.1.1

5 IN  PTR ns1.obando.edu.co.
6 IN  PTR correo.obando.edu.co.
7 IN  PTR sistemas.obando.edu.co.
8 IN  PTR respaldo.obando.edu.co.

EOL"

service bind9 restart
service bind9 status
