# Use a modern, supported version of Debian
FROM debian:bullseye-slim

# Set environment variables to prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install necessary dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      curl \
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

# Expose the port the server runs on
EXPOSE 2358

# The default command to run when the container starts
CMD ["./scripts/server"]
