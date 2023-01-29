# Configurar interfaz en netplan
echo "
network:
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
  version: 2" > /etc/netplan/00-installer-config.yaml

# Aplicar los cambios
netplan try
