# syntax = docker/dockerfile:1

# Use an official Ruby runtime as a parent image
ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Set working directory
WORKDIR /rails

# Set environment variables
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test"

# Base image for building the application
FROM base as build

# Install essential packages and dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config

# Copy the Gemfile and Gemfile.lock into the image
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy the rest of the application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Adjust bin files to be executable on Linux
RUN chmod +x bin/* && \
    sed -i "s/\r$//g" bin/* && \
    sed -i 's/ruby\.exe$/ruby/' bin/*

# Final stage for the application image
FROM base

# Install runtime dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts from the build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Create and use a non-root user for running the application
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Entrypoint prepares the database
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Expose port 3000 for the application
EXPOSE 3000

# Default command to start the server, can be overridden at runtime
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
