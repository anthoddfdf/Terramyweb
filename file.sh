#!/bin/bash
#setting up a welcome MSG
WELCOME_MSG="Welcome To Max Terraform Deployment Success!"

# Create the welcome file and add the message
echo "$WELCOME_MSG" | sudo tee ~/welcome.txt

# Add a command to display the welcome message in .bashrc
if ! grep -q "cat ~/welcome.txt" ~/.bashrc; then
    echo "cat ~/welcome.txt" >> ~/.bashrc
fi



 
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
    <h1>Success! The Nginx web server is installed and running we made a new change to the server.
    https://stock.adobe.com/search?k=congrats.Maxman</h1>
</body>
</html>" | sudo tee /var/www/html/index.html

# Restart Nginx to apply changes
sudo systemctl restart nginx

