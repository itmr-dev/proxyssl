#!/usr/bin/env bash
echo "downloading files"
cd /tmp/
sudo rm -rf /tmp/proxyssl/
sudo git clone https://github.com/itmr-dev/proxyssl.git /tmp/proxyssl/
cd /tmp/proxyssl
echo "starting install"
sudo bash ./install.sh
