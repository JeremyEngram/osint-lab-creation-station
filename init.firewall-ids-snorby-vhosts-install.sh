#!/bin/bash

# Update the system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install iptables and UFW
sudo apt-get install -y iptables ufw

# Configure UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

# Configure iptables with default access control lists (ACLs)
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -j DROP

# Save iptables configuration
sudo sh -c 'iptables-save > /etc/iptables/rules.v4'

# Install Snort IDS
sudo apt-get install -y snort

# Update Snort rules
sudo snort -T -c /etc/snort/snort.conf -i eth0
sudo apt-get install -y snort-rules-default
sudo cp /etc/snort/rules/snort.rules /etc/snort/rules/snort.rules.bak
sudo sh -c 'cat /etc/snort/rules/*.rules > /etc/snort/rules/snort.rules'

# Install Snort GUI - Snorby
sudo apt-get install -y ruby ruby-dev libmysqlclient-dev
sudo gem install snorby

# Configure Snorby
sudo mkdir /var/www/snorby
sudo snorby config -o /var/www/snorby/config.yml
sudo nano /var/www/snorby/config.yml # Edit the configuration file as needed

# Install Apache and Passenger to serve Snorby
sudo apt-get install -y apache2 libapache2-mod-passenger

# Create Apache virtual host for Snorby
sudo sh -c 'echo "<VirtualHost *:80>
    ServerName snorby.example.com
    DocumentRoot /var/www/snorby/public
    <Directory /var/www/snorby/public>
        AllowOverride all
        Options -MultiViews
        Require all granted
    </Directory>
</VirtualHost>" > /etc/apache2/sites-available/snorby.conf'

# Enable the Snorby virtual host and restart Apache
sudo a2ensite snorby
sudo systemctl restart apache2
