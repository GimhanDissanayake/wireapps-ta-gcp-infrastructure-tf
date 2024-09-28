#!/bin/bash

set -x
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/tmp/app_steup.out 2>&1

# Create directory if it doesn't exist
mkdir -p /opt/scripts

# Save the content of appvm_environment_steup.sh to appvm_environment_steup.sh
cat << 'EOF_SCRIPT1' > /opt/scripts/appvm_environment_steup.sh
${script1}
EOF_SCRIPT1

# Save the content of appvm_app_steup.sh to /opt/scripts/appvm_app_steup.sh
cat << 'EOF_SCRIPT2' > /opt/scripts/appvm_app_steup.sh
${script2}
EOF_SCRIPT2

# Make both scripts executable
chmod +x /opt/scripts/appvm_environment_steup.sh
chmod +x /opt/scripts/appvm_app_steup.sh

#########################################
# Install docker
#########################################

#  uninstall all conflicting packages
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install the Docker packages
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y