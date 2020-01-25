#!/bin/bash -Eeu

apt-get install --yes curl
curl --silent --location https://deb.nodesource.com/setup_13.x | bash -
apt-get install --yes nodejs
npm install --global jshint

npm install --global n
# keep old version for backward compatibility with old Katas
n 0.12.7
n 4.1.1
n 4.2.1
n 6.11.1
n 8.2.1
n 8.4.0
n 9.4.0
n 9.10.1
n 10.1.0
n 13.7.0

chmod -R a+w /usr/local
