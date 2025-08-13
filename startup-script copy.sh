#!/bin/bash

echo "Starting Docker installation script..."

echo "Updating package index..."
sudo apt update

echo "Installing Docker package..."
# Add Docker's official GPG key:
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
# Verify Docker installation
sudo docker run hello-world
echo "Docker Version:"
sudo docker version

# Post-installation steps
# Create docker group (might already exist)
sudo groupadd docker

# Add your user to docker group
echo "Adding current user to the docker group..."
sudo usermod -aG docker $USER

# Log out and log back in (or run this command)
newgrp docker

#Enable Docker to start on boot
echo "Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Test without sudo
echo "Docker Version without sudo:"
docker version
docker compose version
docker run hello-world
systemctl status docker
docker info

# Assign ubuntu user to /opt
sudo chown ubuntu:ubuntu -R /opt

sudo cat > /opt/Dockerfile << EOF
# Use the official Nginx image based on Alpine Linux for a small footprint
FROM nginx:alpine

# Maintainer information
LABEL maintainer="Chandra"

# Copy custom index.html to the default Nginx HTML directory
COPY index.html /usr/share/nginx/html/

# Expose port 80 for web traffic
EXPOSE 80
EOF

sudo cat > /opt/index.html << EOF
<!DOCTYPE html>
<html>
<head><title>My Docker App</title></head>
<body>
    <h1>Hello from DockerNew!</h1>
    <p>This app is running in a Docker container on EC2</p>
</body>
</html>
EOF

echo "Docker installation script completed."