# Use the official Jenkins base image
FROM jenkins/jenkins:lts

# Switch to root user to install packages
USER root

# Install sudo, Docker CLI, and dependencies for Ruby installation
RUN apt-get update -qq && \
    apt-get install -y sudo docker.io build-essential libssl-dev libreadline-dev zlib1g-dev wget curl git libffi-dev libyaml-dev && \
    rm -rf /var/lib/apt/lists/*

# Install rbenv and ruby-build
RUN git clone https://github.com/rbenv/rbenv.git /usr/local/rbenv && \
    mkdir -p /usr/local/rbenv/plugins && \
    git clone https://github.com/rbenv/ruby-build.git /usr/local/rbenv/plugins/ruby-build && \
    /usr/local/rbenv/plugins/ruby-build/install.sh

# Set up rbenv environment
ENV PATH="/usr/local/rbenv/bin:/usr/local/rbenv/shims:$PATH"
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh

# Install Ruby 3.2.2 and Bundler
RUN /bin/bash -c 'source /etc/profile.d/rbenv.sh && rbenv install 3.2.2 && rbenv global 3.2.2 && gem install bundler'

# Add Jenkins user to the Docker group
RUN usermod -aG docker jenkins

# Allow Jenkins user to run sudo commands without a password
RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Switch back to Jenkins user
USER jenkins

# Make sure rbenv is initialized for the Jenkins user
ENV PATH="/usr/local/rbenv/bin:/usr/local/rbenv/shims:$PATH"
RUN echo 'eval "$(rbenv init -)"' >> ~/.bashrc
