#!/bin/bash

# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install MariaDB
sudo apt install -y mariadb-server mariadb-client

# Install PM2 globally
sudo npm install -g pm2

# Setup MariaDB
sudo mysql_secure_installation

# Create database and user
sudo mysql -e "
CREATE DATABASE IF NOT EXISTS billing_radius;
CREATE USER IF NOT EXISTS 'billing_admin'@'localhost' IDENTIFIED BY 'SecurePass123!';
GRANT ALL PRIVILEGES ON billing_radius.* TO 'billing_admin'@'localhost';
FLUSH PRIVILEGES;
"

echo "Setup completed!"