# Laboratorio 3
# Crear carpetas
mkdir /var/www/pantoja.com.co.
mkdir /var/www/obando.edu.co.

#Crear archivos index.html
echo "<html>
<head>
<title>Página de pantoja.com.co.</title>
</head>
<body>
<h1>Bienvenidos a pantoja.com.co.</h1>
</body>
</html>" > /var/www/pantoja.com.co./index.html

echo "<html>
<head>
<title>Página de obando.edu.co.</title>
</head>
<body>
<h1>Bienvenidos a obando.edu.co.</h1>
</body>
</html>" > /var/www/obando.edu.co./index.html


#Crear archivos de configuración en /etc/apache2/sites-available/
echo "<VirtualHost *:8080>
ServerAdmin webmaster@localhost
ServerName pantoja.com.co.
ServerAlias www.pantoja.com.co.
DocumentRoot /var/www/pantoja.com.co.
</VirtualHost>" > /etc/apache2/sites-available/pantoja.com.co.conf

echo "<VirtualHost *:8080>
ServerAdmin webmaster@localhost
ServerName obando.edu.co.
ServerAlias www.obando.edu.co.
DocumentRoot /var/www/obando.edu.co.
</VirtualHost>" > /etc/apache2/sites-available/obando.edu.co.conf

#Activar configuración de cada archivo
a2ensite pantoja.com.co.conf
a2ensite obando.edu.co.conf
a2dissite 000-default.conf

Reiniciar Apache
systemctl restart apache2

# Habilitar firewall y permitir puertos ssh y 8080
ufw enable
ufw allow ssh
ufw allow 8080
