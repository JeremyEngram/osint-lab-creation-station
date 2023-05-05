#!/bin/bash

# Update packages and install required software
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y apache2 php8.0 libapache2-mod-php8.0 mysql-server php8.0-mysql bind9 isc-dhcp-server phpmyadmin

# Configure Apache
sudo systemctl enable apache2
sudo systemctl start apache2

# Configure PHP
sudo sed -i 's/^;date\.timezone =$/date\.timezone = UTC/' /etc/php/8.0/apache2/php.ini
sudo systemctl restart apache2

# Configure MySQL
sudo systemctl enable mysql
sudo systemctl start mysql

# Configure MySQL test database and user
mysql -u root -e "CREATE DATABASE testdb;"
mysql -u root -e "CREATE USER 'testuser'@'localhost' IDENTIFIED BY 'testpassword';"
mysql -u root -e "GRANT ALL PRIVILEGES ON testdb.* TO 'testuser'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"

# Configure Bind9
sudo systemctl enable bind9
sudo systemctl start bind9

# Configure DHCP server
sudo systemctl enable isc-dhcp-server
sudo systemctl start isc-dhcp-server

# Basic Bind9 local DNS configuration
cat << EOF | sudo tee /etc/bind/named.conf.local
zone "localnet" {
    type master;
    file "/etc/bind/db.localnet";
};

zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192";
};
EOF

# Basic Bind9 zone files
sudo cp /etc/bind/db.local /etc/bind/db.localnet
sudo cp /etc/bind/db.127 /etc/bind/db.192

# Replace the existing lines with the updated configuration
sudo sed -i 's/^localhost/localnet/' /etc/bind/db.localnet
sudo sed -i 's/^localhost/1.168.192.in-addr.arpa/' /etc/bind/db.192

# Restart Bind9
sudo systemctl restart bind9

# Basic DHCP server configuration
cat << EOF | sudo tee /etc/dhcp/dhcpd.conf
option domain-name "localnet";
option domain-name-servers 192.168.1.1;

default-lease-time 600;
max-lease-time 7200;

subnet 192.168.1.0 netmask 255.255.255.0 {
  range 192.168.1.100 192.168.1.200;
  option routers 192.168.1.1;
}
EOF

# Restart DHCP server
sudo systemctl restart isc-dhcp-server

# Enable and configure phpMyAdmin
sudo phpenmod mbstring
sudo systemctl restart apache2

echo "Installation and configuration completed."
