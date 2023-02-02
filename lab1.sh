#!/bin/bash

# Pasos para tener en cuenta antes de ejecutar el script.
# 1. Iniciar la maquina nueva, e instalar net-tools
# 2. instalar el servicio de isc-dhcp-server
# 3. Apagar la maquina y activar 3 interfaces mas desde el virtualvox
apt update
apt install net-tools -y
apt install isc-dhcp-server -y
apt install bind9 -y
apt install apache2 -y

# Crear carpeta y copiar archivo
mkdir /etc/dhcp3
cp /etc/dhcp/dhcpd.conf /etc/dhcp3/
chmod -R 777 /etc/dhcp3/dhcpd.conf
chmod -R 777 /etc/dhcp3


# Modificar archivo de systemd
sed -i 's#/etc/dhcp/dhcpd.conf#/etc/dhcp3/dhcpd.conf#g' /lib/systemd/system/isc-dhcp-server.service

# Agregar permisos en AppArmor
sed -i '30i\  /etc/dhcp3/dhcpd.conf r,' /etc/apparmor.d/usr.sbin.dhcpd

# Configurar interfaz en netplan
# Para esto vamos a usar una sola interfaz (enp0s8)
# La interfaz enp0s10 la usaremos mas adelante para lab 3
echo "network:
  ethernets:
    enp0s3:
      addresses:
      - 172.16.0.1/16
      - 172.16.0.2/16
      - 172.16.0.3/16
      - 172.16.0.4/16
      - 172.16.0.5/16
      - 172.16.0.6/16
      - 172.16.0.7/16
      - 172.16.0.8/16
    enp0s8:
      addresses:
      dhcp4: true
  version: 2" > /etc/netplan/00-installer-config.yaml

# Aplicar los cambios
netplan try
# Dar una espera de 3 segundos
sleep 3
# Presionar ENTER (Requisito de aplicar los cambios)
#echo -ne '\n'
# Agregar las interfaces correspondientes
sed -i '17s/INTERFACESv4=""/INTERFACESv4="enp0s3"/' /etc/default/isc-dhcp-server
# Agregar las 2 subredes al archivo dhcpd.conf

echo "class \"impresora\" {
  match if (substring(hardware, 1, 6) = 00:00:27:C0:78:FF);
}

class \"device1\" {
  match if (substring(hardware, 1, 6) = 08:00:27:C0:78:FF);
}

subnet 172.16.0.0 netmask 255.255.255.0 {
  pool {
    allow members of \"device1\";
    range 172.16.0.10 172.16.0.50;
  }
  pool {
    allow members of \"impresora\";
    range 172.16.0.51 172.16.0.51;
  }
  pool {
    deny members of \"device1\";
    range 172.16.0.100 172.16.0.200;
  }
  option routers 172.16.0.1;
  option domain-name-servers 8.8.8.8, 8.8.4.4;
  default-lease-time 60;
  max-lease-time 60; 
}" > /etc/dhcp3/dhcpd.conf

# Subir las interfaces
ifconfig enp0s3 up
ifconfig enp0s8 down  

# Iniciamos el servicio
service isc-dhcp-server restart 
service isc-dhcp-server status 
#echo -ne "\x03"





