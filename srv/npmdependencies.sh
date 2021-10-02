#!/bin/bash

cd /var/www/disposable-chat-rooms

echo "INSTALL NODE DEPENDENCIES"

time npm install

echo "INSTALLING BOWER DEPENDENCIES"
time bower --allow-root install