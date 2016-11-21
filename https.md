## Instructions on enabling https

These are guidlines to get a SSL certificate enabled on your vagrant box. To set this up, after `vagrant up` has finished log in to Vagrant with `vagrant ssh` and run the following commands:

```sh
sudo a2enmod ssl
```

```sh
sudo mkdir /etc/apache2/ssl
```

```sh
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt
```


Answer the questions and make sure the Common Name is set to **[site].vg.blueearth.net**
```

Country Name (2 letter code) [AU]:US

State or Province Name (full name) [Some-State]:Minnesota

Locality Name (eg, city) []:Saint Paul

Organization Name (eg, company) [Internet Widgits Pty Ltd]:BEI

Organizational Unit Name (eg, section) []:Dev

Common Name (e.g. server FQDN or YOUR name) []:**[site].vg.blueearth.net**

Email Address []:info@blueearth.net

```

At this point your site should be available at https://[site].vg.blueearth.net
If you want to be able to view your site not secured, you will need to change the vhost. 


```sh
sudo nano /etc/apache2/sites-available/[site].conf
```
```

<VirtualHost *:80 *:443>
    ServerName [site].vg.blueearth.net
    DocumentRoot "/var/www/[site]"
    <Directory "/var/www/[site]">
        AllowOverride All
        Require all granted
    </Directory>
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem
    SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
</VirtualHost>



```
Then restart Apache.

```sh
sudo service apache2 restart
```