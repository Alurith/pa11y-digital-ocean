#! /bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Set the target Chrome version used by Puppeteer.
export TARGET_CHROME_VERSION="127.0.6533.88"

# Install necessary packages and dependencies required by Node.js, Puppeteer, and Chrome.
sudo apt update 
sudo apt upgrade -y
sudo apt install -y nodejs npm ca-certificates fonts-liberation libasound2t64 libatk-bridge2.0-0t64 libatk1.0-0t64 libc6 libcairo2 libcups2t64 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc-s1 libglib2.0-0t64 libgtk-3-0t64 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 lsb-release wget xdg-utils dbus-x11

# Install Pa11y globally 
sudo npm install -g --silent pa11y

# Use Puppeteer's CLI to install the specific version of Chrome.
npx --yes puppeteer browsers install chrome@$TARGET_CHROME_VERSION

# Change ownership of the Chrome sandbox binary to root.
# This is needed because the sandbox requires root ownership to set the correct permissions.
sudo chown root:root /home/app/.cache/puppeteer/chrome/linux-$TARGET_CHROME_VERSION/chrome-linux64/chrome_sandbox 

# Set the permissions on the Chrome sandbox binary.
# The permission 4775 enables the setuid bit, which is required for Chrome's sandbox to work properly.
sudo chmod 4775 /home/app/.cache/puppeteer/chrome/linux-$TARGET_CHROME_VERSION/chrome-linux64/chrome_sandbox 

# Start a new DBus session and export necessary environment variables.
# eval $(dbus-launch --sh-syntax)

# Adjust kernel memory settings to allow memory overcommitment.
# This may help Chrome allocate memory more flexibly.
sudo sysctl -w vm.overcommit_memory=1

# Append environment variable settings to the ~/.bashrc file for persistent configuration.
echo "# Environment variables for Chrome and Puppeteer (set on $(date))" >> ~/.bashrc
echo "export XDG_RUNTIME_DIR=\"/run/user/$UID\"" >> ~/.bashrc
echo "export DBUS_SESSION_BUS_ADDRESS=\"unix:path=/run/user/$UID/bus\"" >> ~/.bashrc
echo "export CHROME_DEVEL_SANDBOX=\"/home/app/.cache/puppeteer/chrome/linux-$TARGET_CHROME_VERSION/chrome-linux64/chrome_sandbox\"" >> ~/.bashrc

# Reload .bashrc so that the new environment variables take effect immediately.
source ~/.bashrc
