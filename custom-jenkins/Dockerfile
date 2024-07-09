# Use the official Jenkins base image
FROM jenkins/jenkins:lts

# Switch to root user to install packages
USER root

# Install sudo and Docker CLI
RUN apt-get update -qq && \
    apt-get install -y sudo docker.io && \
    rm -rf /var/lib/apt/lists/*

# Add Jenkins user to the Docker group
RUN usermod -aG docker jenkins

# Allow Jenkins user to run sudo commands without a password
RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Switch back to Jenkins user
USER jenkins
