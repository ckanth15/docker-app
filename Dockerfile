# Use the official Nginx image based on Alpine Linux for a small footprint
FROM nginx:alpine

# Maintainer information
LABEL maintainer="Chandra"

# Copy custom index.html to the default Nginx HTML directory
COPY index.html /usr/share/nginx/html/

# Expose port 80 for web traffic
EXPOSE 80