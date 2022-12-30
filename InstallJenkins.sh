#! /bin/bash

# Download and Install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum upgrade
# Add required dependencies for the jenkins package
sudo yum install java-11-amazon-corretto.x86_64


#  Install Jenkins
sudo yum install jenkins

sudo systemctl daemon-reload

sudo systemctl enable jenkins

# Start Jenkins
sudo systemctl start jenkins

# Install Git SCM
yum install git -y

# Make sure Jenkins comes up/on when reboot
chkconfig jenkins on