#!/bin/bash

set -x
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/tmp/environment_steup.out 2>&1

##########################################################################
# Install Node.js and npm
##########################################################################

# Update the package list
sudo apt update -y

# Install required dependencies
sudo apt install -y curl

# Add NodeSource APT repository for the latest version of Node.js (e.g., Node 18.x)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -

# Install Node.js and npm
sudo apt install -y nodejs

# Verify installation
node -v
npm -v

echo "Node.js and npm installation completed."

##########################################################################
# Install Nginx
##########################################################################

# Install Nginx
sudo apt install -y nginx

# Start and enable Nginx service
sudo systemctl start nginx
sudo systemctl enable nginx

# Verify Nginx installation
nginx -v

echo "Node.js, npm, and Nginx installation completed."

##########################################################################
# Create Nginx configuration files
##########################################################################

# Create Nginx configuration for web.example.com
sudo bash -c 'cat > /etc/nginx/sites-available/web.example.com <<EOF
server {
    listen 80;
    server_name web.example.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF'

# Create Nginx configuration for api.example.com
sudo bash -c 'cat > /etc/nginx/sites-available/api.example.com <<EOF
server {
    listen 80;
    server_name api.example.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF'

# Enable the new configurations by creating symlinks
sudo ln -s /etc/nginx/sites-available/web.example.com /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/api.example.com /etc/nginx/sites-enabled/

# Test Nginx configuration for syntax errors
sudo nginx -t

# Reload Nginx to apply the new configurations
sudo systemctl reload nginx

echo "Node.js, npm, Nginx, and virtual hosts setup completed."

##########################################################################
# Install Certbot and provision SSL certificates
##########################################################################

# Install Certbot and Nginx plugin for SSL
sudo apt install -y certbot python3-certbot-nginx

# Obtain SSL certificates for both web.example.com and api.example.com using Certbot
sudo certbot --nginx -d web.subdomain.example.com -d api.subdomain.example.com --non-interactive --agree-tos -m gimhanem@gmail.com

# Test Nginx configuration for SSL and reload Nginx
sudo nginx -t
sudo systemctl reload nginx

echo "Node.js, npm, Nginx, and SSL setup completed with Certbot."