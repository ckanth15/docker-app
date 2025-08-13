# docker-app

Complete Docker Assignment Using Docker Compose
Yes, absolutely! Docker Compose is actually better for multi-container applications. Let me provide the complete assignment using Docker Compose.
Prerequisites

EC2 instance running (Ubuntu 20.04 or later)
SSH access to your EC2 instance


Task 1: Environment Setup

Connect to EC2 and install Docker:
bashsudo apt update
sudo apt install docker.io docker-compose -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

Log out and back in, then verify:
bashdocker --version
docker-compose --version



Task 2: Create Project Structure

Create project directory:
bashmkdir docker-compose-assignment
cd docker-compose-assignment

Create the web application files:
Create web/index.html:
bashmkdir web
cat > web/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>My Docker Compose App</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 600px; margin: 0 auto; }
        .status { background: #e8f5e8; padding: 10px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Hello from Docker Compose!</h1>
        <div class="status">
            <p><strong>Environment:</strong> \${APP_ENV}</p>
            <p><strong>Version:</strong> \${APP_VERSION}</p>
            <p><strong>Container:</strong> Web Server</p>
        </div>
        <p>This multi-container app is running on EC2 using Docker Compose</p>
        <p>Web server + Redis are running in separate containers</p>
    </div>
</body>
</html>
EOF
Create web/Dockerfile:
bashcat > web/Dockerfile << EOF
FROM nginx:alpine

# Add curl for health checks
RUN apk add --no-cache curl

# Copy website files
COPY index.html /usr/share/nginx/html/

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

EXPOSE 80
EOF



Task 3: Create Docker Compose File
Create docker-compose.yml:
bashcat > docker-compose.yml << EOF
version: '3.8'

services:
  web:
    build: ./web
    ports:
      - "80:80"
    environment:
      - APP_ENV=production
      - APP_VERSION=2.0
    depends_on:
      - redis
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 30s
      timeout: 3s
      retries: 3

  redis:
    image: redis:alpine
    volumes:
      - redis-data:/data
    networks:
      - app-network
    restart: unless-stopped
    command: redis-server --appendonly yes
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 3s
      retries: 3

volumes:
  redis-data:
    driver: local

networks:
  app-network:
    driver: bridge
EOF

Task 4: Deploy the Application

Start the application:
bashdocker-compose up -d

Check status:
bashdocker-compose ps

View logs:
bash# All services
docker-compose logs

# Specific service
docker-compose logs web
docker-compose logs redis

# Follow logs
docker-compose logs -f

Test the application:

Visit: http://your-ec2-public-ip
Should see your webpage with environment variables




Task 5: Working with the Multi-Container App
Test Redis Connectivity:
bash# Connect to Redis container
docker-compose exec redis redis-cli

# In Redis CLI, test data:
SET mykey "Hello from Docker Compose!"
GET mykey
exit
Test Web Container:
bash# Execute commands in web container
docker-compose exec web sh

# Inside container:
curl http://redis:6379  # Test network connectivity
exit

Bonus Challenges with Docker Compose
Challenge 1: Environment Variables (Already Implemented!)
Check current environment variables:
bashdocker-compose exec web env | grep APP
Update environment variables:
bash# Edit docker-compose.yml to change environment values
nano docker-compose.yml

# Recreate containers with new environment
docker-compose up -d --force-recreate
Challenge 2: Volume Persistence (Already Implemented!)
Test Redis data persistence:
bash# Add data to Redis
docker-compose exec redis redis-cli SET persistent-key "This data survives restarts"

# Restart Redis service
docker-compose restart redis

# Check if data persists
docker-compose exec redis redis-cli GET persistent-key
Inspect volume:
bashdocker volume inspect docker-compose-assignment_redis-data
Challenge 3: Health Checks (Already Implemented!)
Check health status:
bashdocker-compose ps
View detailed health information:
bashdocker inspect $(docker-compose ps -q web) | grep -A 20 Health
docker inspect $(docker-compose ps -q redis) | grep -A 20 Health
Challenge 4: Container Lifecycle Management
All the lifecycle commands:
bash# Stop all services
docker-compose stop

# Start stopped services
docker-compose start

# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart web

# Stop and remove containers (keeps volumes)
docker-compose down

# Stop and remove containers + volumes
docker-compose down -v

# Stop and remove containers + images
docker-compose down --rmi all

# View resource usage
docker-compose top

# Scale services (run multiple instances)
docker-compose up -d --scale web=2

# Update and recreate services
docker-compose up -d --build

Advanced Docker Compose Features
1. Development vs Production Configs
Create docker-compose.override.yml (for development):
bashcat > docker-compose.override.yml << EOF
version: '3.8'

services:
  web:
    ports:
      - "8080:80"  # Different port for dev
    environment:
      - APP_ENV=development
      - APP_VERSION=dev-1.0
    volumes:
      - ./web:/usr/share/nginx/html  # Live reload

  redis:
    ports:
      - "6379:6379"  # Expose Redis port in dev
EOF
Create docker-compose.prod.yml (for production):
bashcat > docker-compose.prod.yml << EOF
version: '3.8'

services:
  web:
    environment:
      - APP_ENV=production
      - APP_VERSION=prod-2.0
    restart: always

  redis:
    restart: always
EOF
Use different configs:
bash# Development mode
docker-compose up -d

# Production mode
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
2. Add Monitoring
Add to docker-compose.yml:
yaml  nginx-exporter:
    image: nginx/nginx-prometheus-exporter:latest
    ports:
      - "9113:9113"
    command: -nginx.scrape-uri http://web:80/stub_status
    depends_on:
      - web
    networks:
      - app-network

Complete Project Structure
docker-compose-assignment/
├── docker-compose.yml
├── docker-compose.override.yml
├── docker-compose.prod.yml
└── web/
    ├── Dockerfile
    └── index.html

Useful Docker Compose Commands Summary
bash# Basic operations
docker-compose up -d                    # Start in background
docker-compose down                     # Stop and remove
docker-compose restart                  # Restart all services
docker-compose ps                       # List services
docker-compose logs -f                  # Follow logs

# Building and updating
docker-compose build                    # Build images
docker-compose up -d --build           # Build and start
docker-compose pull                     # Pull latest images

# Scaling and management
docker-compose up -d --scale web=3     # Scale web service
docker-compose exec web sh             # Execute in container
docker-compose top                      # Show running processes

# Cleanup
docker-compose down -v --rmi all       # Remove everything
This Docker Compose approach is much cleaner and more professional than individual Docker commands. It's exactly how you'd manage applications in production!CKinstead of docker.io can we get the exact correct steps from docekr websiteAbsolutely! Let me provide the official Docker installation steps directly from Docker's documentation for Ubuntu on EC2.
Official Docker Installation Steps for Ubuntu EC2
Method 1: Install using the apt repository (Recommended)
1. Set up Docker's apt repository
bash# Add Docker's official GPG key:
sudo apt-get update
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
2. Install Docker packages
bashsudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
3. Verify installation
bashsudo docker run hello-world
4. Post-installation steps (Important!)
bash# Create docker group (might already exist)
sudo groupadd docker

# Add your user to docker group
sudo usermod -aG docker $USER

# Log out and log back in (or run this command)
newgrp docker

# Test without sudo
docker run hello-world
5. Enable Docker to start on boot
bashsudo systemctl enable docker.service
sudo systemctl enable containerd.service

Method 2: Install using convenience script (Alternative)
bashcurl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

Install Docker Compose
Docker Compose is now included as a Docker plugin, but you can also install it separately:
Option A: Use Docker Compose Plugin (Recommended - Already installed above)
bashdocker compose version
Option B: Install Docker Compose separately
bash# Download latest version
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make it executable
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker-compose --version

Verification Commands
After installation, run these to verify everything is working:
bash# Check Docker version
docker --version

# Check Docker Compose version (plugin version)
docker compose version

# Check Docker Compose version (standalone version)
docker-compose --version

# Check Docker service status
sudo systemctl status docker

# Test Docker without sudo
docker run hello-world

# Check Docker info
docker info

Updated Docker Compose Commands
Important: With the new Docker Compose plugin, you can use either:

docker compose (new plugin syntax)
docker-compose (classic standalone syntax)

Updated docker-compose.yml for the assignment:
bashmkdir docker-compose-assignment
cd docker-compose-assignment

# Create the directory structure
mkdir web

# Create web/index.html
cat > web/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>My Docker Compose App</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .status { background: #e8f5e8; padding: 15px; border-radius: 5px; margin: 20px 0; }
        h1 { color: #2c3e50; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🐳 Hello from Docker Compose!</h1>
        <div class="status">
            <p><strong>🌍 Environment:</strong> Production</p>
            <p><strong>📦 Version:</strong> 2.0</p>
            <p><strong>🖥️ Container:</strong> Web Server (Nginx)</p>
            <p><strong>💾 Database:</strong> Redis Connected</p>
        </div>
        <p>✅ This multi-container application is running on AWS EC2</p>
        <p>🔧 Built with Docker Compose official installation</p>
        <p>🚀 Web server + Redis running in separate containers</p>
    </div>
</body>
</html>
EOF

# Create web/Dockerfile
cat > web/Dockerfile << 'EOF'
FROM nginx:alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Copy website files
COPY index.html /usr/share/nginx/html/

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

EXPOSE 80
EOF

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
services:
  web:
    build: ./web
    ports:
      - "80:80"
    environment:
      - APP_ENV=production
      - APP_VERSION=2.0
      - NGINX_HOST=localhost
    depends_on:
      - redis
    networks:
      - app-network
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    volumes:
      - redis-data:/data
    networks:
      - app-network
    restart: unless-stopped
    command: redis-server --appendonly yes
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 3s
      retries: 5
      start_period: 30s

volumes:
  redis-data:
    driver: local

networks:
  app-network:
    driver: bridge
EOF

Run the Application with Official Docker
bash# Using new Docker Compose plugin syntax
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs

# Test Redis
docker compose exec redis redis-cli ping

# Stop application
docker compose down

# Clean up everything
docker compose down -v --rmi all

Key Differences from docker.io installation:

Source: Official Docker repositories vs Ubuntu's repositories
Version: Latest stable Docker version vs potentially older version
Updates: Direct updates from Docker vs Ubuntu package updates
Features: Includes latest Docker features and plugins
Support: Official Docker support and documentation

Why use official Docker installation?

✅ Latest features and security updates
✅ Better performance and stability
✅ Official support and documentation
✅ Includes Docker Compose plugin
✅ Regular updates directly from Docker

This is the exact same method used in production environments and is the recommended approach from Docker's official documentation!