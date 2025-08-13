#!/bin/bash

echo "Starting Docker installation script..."

echo "Updating package index..."
sudo apt update

echo "Installing Docker package..."
sudo apt install docker.io -y

echo "Starting Docker service..."
sudo systemctl start docker

echo "Enabling Docker to start on boot..."
sudo systemctl enable docker

echo "Adding current user to the docker group..."
sudo usermod -aG docker $USER

echo "Docker Version:"
sudo docker version

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

# Docker build
cd /opt
sudo docker build -t my-nginx-image .
docker run -d -p 80:80 --name web-container my-nginx-image
echo "Nginx Docker container my-nginx-image is running on port 80."
echo "To access the Nginx server, open your web browser and use your public ip of ec2 instance to access it."
echo "Docker installation script completed."