#!/usr/bin/env bash
echo "getting installer"
echo "changing to temp folder"
cd /tmp/
echo "removing old cached installer versions"
sudo rm -rf /tmp/proxyssl/
echo "checking if git is installed"
if ! command -v git &> /dev/null
then
    echo "git not found installing now"
    apt install git -y
    exit
fi
echo "cloning repository to tmp"
sudo git clone https://github.com/itmr-dev/proxyssl.git /tmp/proxyssl/
echo "changing to installer directory"
cd /tmp/proxyssl
echo "starting install"
sudo bash ./install.sh
