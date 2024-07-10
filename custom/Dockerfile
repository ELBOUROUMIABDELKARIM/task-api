FROM jenkins/jenkins:lts

USER root

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl git build-essential libssl-dev libreadline-dev zlib1g-dev libsqlite3-dev

# Install rbenv and ruby-build
RUN git clone https://github.com/rbenv/rbenv.git /root/.rbenv && \
    git clone https://github.com/rbenv/ruby-build.git /root/.rbenv/plugins/ruby-build && \
    /root/.rbenv/plugins/ruby-build/install.sh

# Set up rbenv environment variables
ENV PATH="/root/.rbenv/bin:/root/.rbenv/shims:${PATH}"

# Install Ruby 3.0.0
RUN rbenv install 3.0.0 && \
    rbenv global 3.0.0 && \
    gem install bundler

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

USER jenkins
