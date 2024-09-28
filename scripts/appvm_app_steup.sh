#!/bin/bash

set -x
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/tmp/app_steup.out 2>&1

##########################################################################
# WEB APP
##########################################################################

# Define variables for git repositories
WEB_APP_REPO="git@github.com:GimhanDissanayake/wireapps-ta-web-app.git"

# Define environment variables for the web app
WEB_PORT=8000
API_HOST="http://localhost:8080"

# Define directories to clone the apps
WEB_APP_DIR="/usr/src/web-app"

# Clone or pull the latest changes for the web app
if [ -d "$WEB_APP_DIR" ]; then
    echo "Web app directory exists. Pulling latest changes..."
    cd "$WEB_APP_DIR"
    git pull origin main
else
    echo "Cloning web app repository..."
    git clone "$WEB_APP_REPO" "$WEB_APP_DIR"
    cd "$WEB_APP_DIR"
fi

# Set environment variables for the web app
export PORT=$WEB_PORT
export API_HOST=$API_HOST

# Build and restart the web app using Docker
echo "Building the web app Docker image..."
docker build -t web-app "$WEB_APP_DIR"

echo "Restarting the web app container..."
docker stop web-app || true
docker rm web-app || true
docker run -d --name web-app -p $WEB_PORT:$WEB_PORT --env PORT=$PORT --env API_HOST=$API_HOST web-app

echo "Web application has been successfully built and restarted."


##########################################################################
# API APP
##########################################################################

# Define variables for git repositories
API_APP_REPO="git@github.com:GimhanDissanayake/wireapps-ta-api-app.git"

# Define environment variables for the API app
API_PORT=8080
DB_CONN="postgres://postgres:admin@localhost/postgres"

# Define directories to clone the apps
API_APP_DIR="/usr/src/api-app"

# Clone or pull the latest changes for the API app
if [ -d "$API_APP_DIR" ]; then
    echo "API app directory exists. Pulling latest changes..."
    cd "$API_APP_DIR"
    git pull origin main
else
    echo "Cloning API app repository..."
    git clone "$API_APP_REPO" "$API_APP_DIR"
    cd "$API_APP_DIR"
fi

# Set environment variables for the API app
export PORT=$API_PORT
export DB=$DB_CONN

# Build and restart the API app using Docker
echo "Building the API app Docker image..."
docker build -t api-app "$API_APP_DIR"

echo "Restarting the API app container..."
docker stop api-app || true
docker rm api-app || true
docker run -d --name api-app -p $API_PORT:8080 --env PORT=$PORT --env DB=$DB api-app

echo "API application have been successfully built and restarted."
