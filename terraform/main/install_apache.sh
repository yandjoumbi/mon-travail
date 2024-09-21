#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Hello World from my name is yannick and i am located by $(hostname -f)" > /var/www/html/index.html