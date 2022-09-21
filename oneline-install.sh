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
    sudo apt install git -y
else
    echo "git requirement satisfied"
fi
echo "cloning repository to tmp"
git clone https://github.com/itmr-dev/proxyssl.git /tmp/proxyssl/
echo "changing to installer directory"
cd /tmp/proxyssl
echo "starting install"
clear
bash ./install.sh
