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
docker version

echo "Docker installation script completed."