# Use the official Nginx image as the base image
FROM nginx:latest

# Copy the index.html file into the Nginx html directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80 to allow outside access
EXPOSE 80