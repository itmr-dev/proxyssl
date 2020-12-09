#!/usr/bin/env bash
echo "downloading files"
cd /tmp/
sudo rm -rf /tmp/itmr-proxyssl/
sudo git clone https://github.com/itmr-dev/itmr-proxyssl.git /tmp/itmr-proxyssl/
sudo cd /tmp/itmr-proxyssl
echo "starting install"
sudo bash ./install.sh
