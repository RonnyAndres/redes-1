#!/bin/bash

# Crear carpeta y copiar archivo
mkdir /etc/dhcp3
cp /etc/dhcpd/dhcpd.conf /etc/dhcp3/
chmod -R 777 /etc/dhcp3/dhcpd.conf

# Modificar archivo de systemd
sed -i 's#/etc/dhcp/dhcpd.conf#/etc/dhcp3/dhcpd.conf#g' /lib/systemd/system/isc-dhcp-server.service

# Agregar permisos en AppArmor
echo "/etc/dhcp3/dhcpd.conf r," >> /etc/apparmor.d/usr.sbin.dhcp

# Configurar interfaz en netplan
echo "
network:
  ethernets:
    enp0s3:
      dhcp4: true
    enp0s8:
      addresses:
      - 192.168.1.255/24
      gateway4: 192.168.0.1
      nameservers:
        addresses:
        - 8.8.8.8
   version: 2"> /etc/netplan/00-installer-config.yaml
netplan try
