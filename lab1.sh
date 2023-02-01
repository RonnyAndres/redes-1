#!/bin/bash

# Pasos para tener en cuenta antes de ejecutar el script.
# 1. Iniciar la maquina nueva, e instalar net-tools
# 2. instalar el servicio de isc-dhcp-server
# 3. Apagar la maquina y activar 3 interfaces mas desde el virtualvox

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
      dhcp4: true
    enp0s8:
      addresses:
      - 172.16.100.255/24
      gateway4: 172.16.100.1
      nameservers:
        addresses:
        - 8.8.8.8
        - 8.8.4.4
    enp0s10: 
      dhcp4: no
      addresses:
      - 192.168.1.10/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
        - 8.8.8.8
        - 8.8.4.4
  version: 2" > /etc/netplan/00-installer-config.yaml

# Aplicar los cambios
netplan try
# Dar una espera de 3 segundos
sleep 3
# Presionar ENTER (Requisito de aplicar los cambios)
#echo -ne '\n'
# Agregar las interfaces correspondientes
sed -i '17s/INTERFACESv4=""/INTERFACESv4="enp0s8"/' /etc/default/isc-dhcp-server
# Agregar las 2 subredes al archivo dhcpd.conf

echo "class \"impresora\" {
  match if (substring(hardware, 1, 6) = 00:00:27:C0:78:FF);
}

class \"device1\" {
  match if (substring(hardware, 1, 6) = 09:00:27:C0:78:FF);
}

subnet 172.16.100.0 netmask 255.255.255.0 {
  pool {
    allow members of \"device1\";
    range 172.16.100.10 172.16.100.50;
  }
  pool {
    allow members of \"impresora\";
    range 172.16.100.51 172.16.100.51;
  }
  pool {
    deny members of \"device1\";
    range 172.16.100.100 172.16.100.200;
  }
  option routers 172.16.100.1;
  option domain-name-servers 8.8.8.8, 8.8.4.4;
  default-lease-time 60;
  max-lease-time 60; 
}">> /etc/dhcp3/dhcpd.conf

# Subir las interfaces
ifconfig enp0s8 up
ifconfig enp0s3 down 
ifconfig enp0s10 down 

# Iniciamos el servicio
service isc-dhcp-server restart 
service isc-dhcp-server status 
#echo -ne "\x03"





