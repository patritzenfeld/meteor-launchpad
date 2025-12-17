#!/bin/bash

set -e

printf "\n[-] Installing NVM...\n\n"

# Install NVM
export NVM_DIR="/opt/nvm"
mkdir -p $NVM_DIR

curl --retry 20 --retry-delay 10 -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# Load NVM
. $NVM_DIR/nvm.sh

# Determine Node version based on NODE_VERSION env var or Meteor version
if [ -n "$NODE_VERSION" ]; then
  # Use explicitly provided NODE_VERSION
  printf "\n[-] Using explicitly defined Node.js version: $NODE_VERSION\n\n"
else
  # Auto-detect from Meteor version
  METEOR_RELEASE_FILE="$APP_SOURCE_DIR/.meteor/release"
  
  if [ -f "$METEOR_RELEASE_FILE" ]; then
    METEOR_VERSION=$(head "$METEOR_RELEASE_FILE" | cut -d "@" -f 2)
    METEOR_MAJOR_VERSION=$(echo "$METEOR_VERSION" | cut -d "." -f 1)
    
    printf "\n[-] Detected Meteor version: $METEOR_VERSION\n"
    
    # Determine Node version based on Meteor major version
    if [ "$METEOR_MAJOR_VERSION" -ge 3 ]; then
      NODE_VERSION="24"
      printf "\n[-] Meteor v3+ detected. Using Node.js latest v24...\n\n"
    else
      NODE_VERSION="14"
      printf "\n[-] Meteor v2 detected. Using Node.js latest v14...\n\n"
    fi
  else
    # Fallback if release file doesn't exist
    NODE_VERSION="24"
    printf "\n[-] Could not detect Meteor version. Defaulting to Node.js latest v24...\n\n"
  fi
fi

# Install the determined Node version using NVM
nvm install $NODE_VERSION
nvm alias default $NODE_VERSION
nvm use default

printf "\n[-] Node.js $(node -v) installed successfully\n\n"

# Create symlinks for system-wide access
ln -sf $NVM_DIR/versions/node/$(nvm version default)/bin/node /usr/bin/node
ln -sf $NVM_DIR/versions/node/$(nvm version default)/bin/npm /usr/bin/npm
