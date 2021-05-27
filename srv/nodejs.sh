#!/bin/bash


ACTIVE_BRANCH="master"
SERVER_PATH="/var/www"

echo "INSTALLING DEPENDENCIES"

# install node via nvm
echo "INSTALL NODE LTS"
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs

echo "node version"
echo `which node && node -v`
echo ""
echo "npm version"
echo `which npm && npm -v`






