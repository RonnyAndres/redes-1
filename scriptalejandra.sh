#!/bin/bash

# Crear carpeta y copiar archivo
mkdir /etc/dhcpprueba
cp /etc/dhcp/dhcpd.conf /etc/dhcpprueba/
chmod -R 777 /etc/dhcpprueba/dhcpd.conf
chmod -R 777 /etc/dhcpprueba


# Modificar archivo de systemd
sed -i 's#/etc/dhcp/dhcpd.conf#/etc/dhcpprueba/dhcpd.conf#g' /lib/systemd/system/isc-dhcp-server.service

# Agregar permisos en AppArmor
sed -i '30i\  /etc/dhcpprueba/dhcpd.conf r,' /etc/apparmor.d/usr.sbin.dhcpd

# Configurar interfaz en netplan
echo "network:
  ethernets:
    enp0s3:
      dhcp4: true
    enp0s8:
      addresses:
      - 172.100.100.255/24
      gateway4: 172.100.100.1
      nameservers:
        addresses:
        - 8.8.8.8
        - 8.8.4.4
    enp0s9:
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
      - 192.168.255.255/24
      gateway4: 192.168.255.1
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
sed -i '17s/INTERFACESv4=""/INTERFACESv4="enp0s8 enp0s9 enp0s10"/' /etc/default/isc-dhcp-server
# Agregar las 2 subredes al archivo dhcpd.conf

echo "subnet 172.100.100.0 netmask 255.255.255.0 {
  range 172.100.100.100 172.100.100.200;
  option routers 172.100.100.1;
  option domain-name-servers 8.8.8.8, 8.8.4.4;
  default-lease-time 60;
  max-lease-time 60;
}
class \"impresora\" {
  match if (substring(hardware, 1, 6) = 00:00:27:C0:78:FF);
}
class \"pc1\" {
  match if (substring(hardware, 1, 6) = 09:00:27:C0:78:FF);
}
subnet 172.16.100.0 netmask 255.255.255.0 {
  pool {
    allow members of \"pc1\";
    range 172.16.100.10 172.16.100.50;
  }
  pool {
    allow members of \"impresora\";
    range 172.16.100.51 172.16.100.51;
  }
  option routers 172.16.100.1;
  option domain-name-servers 8.8.8.8, 8.8.4.4;
  default-lease-time 60;
  max-lease-time 60; 
}">> /etc/dhcpprueba/dhcpd.conf

# Subir las interfaces
ifconfig enp0s8 up
ifconfig enp0s9 up
ifconfig enp0s3 down 

# Iniciamos el servicio
service isc-dhcp-server restart 
service isc-dhcp-server status 
#echo -ne "\x03"
