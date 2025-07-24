# This is the final, most robust Dockerfile for deploying Judge0.
# It uses a modern base image, the correct entrypoint, and fixes line ending and permission issues.

# Use a modern, supported version of Debian
FROM debian:bullseye-slim

# Set environment variables to prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install necessary dependencies
# --- FIX: Added 'cron' and 'dos2unix' ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      cron \
      curl \
      dos2unix \
      git \
      libpq-dev \
      libseccomp-dev \
      libyaml-dev \
      nodejs \
      npm \
      pkg-config \
      postgresql-client \
      ruby-dev \
      sudo && \
    rm -rf /var/lib/apt/lists/*

# Install a specific version of bundler
RUN echo "gem: --no-document" > /root/.gemrc && \
    gem install bundler:2.1.4

# Set up the application directory
WORKDIR /usr/src/app

# Copy the application files
COPY . .

# Install Ruby dependencies
RUN bundle install --deployment --without development test

# Install Node.js dependencies
RUN npm install --production

# --- FIX: Convert all scripts to Unix format and make them executable ---
# This now correctly targets all necessary scripts, not just .sh files.
RUN find /usr/src/app/scripts -type f -exec dos2unix {} + && \
    find /usr/src/app/scripts -type f -exec chmod +x {} + && \
    dos2unix /usr/src/app/docker-entrypoint.sh && \
    chmod +x /usr/src/app/docker-entrypoint.sh

# Expose the port the server runs on
EXPOSE 2358

# Use the official entrypoint and command
# This ensures the server waits for the database before starting.
ENTRYPOINT ["/usr/src/app/docker-entrypoint.sh"]
CMD ["./scripts/server"]
