#!/bin/bash

# Prompt for SMTP Server settings
read -p "Enter SMTP Server: " smtp_server
read -p "Enter SMTP Port: " smtp_port
read -p "Enter SMTP User: " smtp_user
read -p "Enter SMTP Password: " smtp_password
read -p "Enter Tripwire Passphrase: " tripwire_passphrase

# Install Tripwire
sudo apt update
sudo apt install tripwire -y

# Initialize Tripwire
sudo tripwire --init

# Edit Tripwire Configuration File
sudo cp /etc/tripwire/twcfg.txt /etc/tripwire/twcfg.txt.orig
sudo sed -i 's|/usr/sbin/sendmail|/usr/bin/mail|g' /etc/tripwire/twcfg.txt
sudo sed -i 's|^TWREPORTGEN .*|TWREPORTGEN = "/usr/bin/genhtml"|g' /etc/tripwire/twcfg.txt
sudo sed -i 's|/usr/sbin/|/usr/bin/|g' /etc/tripwire/twcfg.txt
sudo sed -i "s|^MAILMETHOD.*|MAILMETHOD = SMTP|g" /etc/tripwire/twcfg.txt
sudo sed -i "s|^SMTPHOST.*|SMTPHOST = ${smtp_server}|g" /etc/tripwire/twcfg.txt
sudo sed -i "s|^SMTPPORT.*|SMTPPORT = ${smtp_port}|g" /etc/tripwire/twcfg.txt
sudo sed -i "s|^SMTPUSER.*|SMTPUSER = ${smtp_user}|g" /etc/tripwire/twcfg.txt
sudo sed -i 's|^SMTPEXEMODE.*|SMTPEXEMODE = starttls|g' /etc/tripwire/twcfg.txt
sudo sed -i "s|^SMTPPASS.*|SMTPPASS = ${smtp_password}|g" /etc/tripwire/twcfg.txt
sudo sed -i 's|^SITEKEYFILE.*|SITEKEYFILE = /etc/tripwire/site.key|g' /etc/tripwire/twcfg.txt

# Generate the site key
sudo twadmin -m G -S /etc/tripwire/site.key

# Update the policy file
sudo twadmin -m P /etc/tripwire/twpol.txt

# Set the Tripwire passphrase
sudo tripwire --passwd ${tripwire_passphrase}

# Generate Tripwire Database
sudo tripwire --update -v

# Create a report
sudo tripwire --check -v > /tmp/tw-report.txt

# Email the report
sudo tripwire --check -v --email-report
