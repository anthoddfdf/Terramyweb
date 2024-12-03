#!/bin/bash
# Update package lists
sudo apt-get update

# Install Nginx
sudo apt-get install -y nginx

# Start Nginx service
sudo systemctl start nginx

# Enable Nginx to start on boot
sudo systemctl enable nginx

# Create a simple HTML file to serve
echo "<html>
<head>
    <title>Welcome to Nginx!</title>
</head>
<body>
    <h1>Success! The Nginx web server is installed and running.</h1>
</body>
</html>" | sudo tee /var/www/html/index.html

# Restart Nginx to apply changes
sudo systemctl restart nginx