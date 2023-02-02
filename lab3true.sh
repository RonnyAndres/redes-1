mkdir -p /var/www/pantoja.com.co/privado
mkdir -p /var/www/obando.edu.co


echo "<html>
<head>
<title>Página de pantoja.com.co.</title>
</head>
<body>
<h1>Bienvenidos a pantoja.com.co.</h1>
</body>
</html>" > /var/www/pantoja.com.co/index.html

echo "<html>
<head>
<title>Página de obando.edu.co.</title>
</head>
<body>
<h1>Bienvenidos a obando.edu.co.</h1>
</body>
</html>" > /var/www/obando.edu.co/index.html

chown -R www-data: /var/www/pantoja.com.co
chown -R www-data: /var/www/obando.edu.co

touch /etc/apache2/sites-available/pantoja.com.co.conf
touch /etc/apache2/sites-available/obando.edu.co.conf

echo "<VirtualHost *:80>
              ServerAdmin webmaster@localhost
              ServerName sistemas.pantoja.com.co
              DocumentRoot /var/www/pantoja.com.co
              ErrorDocument 404 "No found page"
              <Directory "/var/www/pantoja.com.co/privado">
                AuthType Basic
                AuthName "Restricted Content"
                AuthuserFile /var/www/pantoja.com.co/privado/.htpasswd
                Require valid-user
              </Directory> 
</VirtualHost>" > /etc/apache2/sites-available/pantoja.com.co.conf

echo "<VirtualHost *:8080>
              ServerAdmin webmaster@localhost
              ServerName respaldo.obando.edu.co
              DocumentRoot /var/www/obando.edu.co
              ErrorLog ${APACHE_LOG_DIR}/error.log
              CustomLog ${APACHE_LOG_DIR}/access.log combined
      Redirect 301 /google http://google.com
</VirtualHost>" > /etc/apache2/sites-available/obando.edu.co.conf

cd /etc/apache2/sites-available

a2ensite pantoja.com.co.conf
a2ensite obando.edu.co.conf

systemctl reload apache2

# Tercer punto ---------------------------------------------------------

cd /home/ronny/var/www/pantoja.com.co/privado

htpasswd -c /home/ronny/var/www/pantoja.com.co/privado/.htpasswd ronny

# 123

apache2ctl configtest 
systemctl restart apache2
systemctl status apache2


# Quinto punto 

a2enmod info

# /etc/apache2/mods-enabled/status.conf
 <Location "/server-status">
      SetHandler server-status
      Require local
      Require ip 172.16.0.10
 </Location>
 
systemctl restart apache2
systemctl status apache2



