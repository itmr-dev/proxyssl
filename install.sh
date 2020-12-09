#!/usr/bin/env bash

echo "Beginning proxyssl setup"

echo "installing cron"
sudo apt install cron -y

echo "installing snap & certbot"
sudo apt update
sudo apt install snapd -y
sudo snap install core; sudo snap refresh core
sudo apt-get remove certbot -y
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

echo "installing haproxy"
apt-get -y install wget vim haproxy

echo "installing nvm"
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash

echo "reloading bash"
source ~/.bashrc

echo "setting up nvm"
nvm install 13
nvm use 13

echo "installing pm2"
npm i -g pm2

echo "removing standard configs & scripts"
sudo rm /etc/letsencrypt/cli.ini
sudo rm /etc/cron.d/cerbot
sudo rm /etc/haproxy/haproxy.cfg

echo "creating letsencrypt folder"
sudo mkdir /etc/letsencrypt

echo "copying new configs & scripts"
sudo cp ./configs/certbot /etc/cron.d/
sudo cp ./configs/cli.ini /etc/letsencrypt/
sudo cp ./configs/haproxy.cfg /etc/haproxy/

echo "installing mustache"
curl -sSL https://git.io/get-mo -o mo
. "mo"
echo "Mustache was installed successfully" | mo

echo ""
read -p 'which domains should be configured? (seperated by spaces) > ' domains

echo "recieved following domains:"
domainsArr=$(echo $domains | tr " " "\n")
for x in $domainsArr
do
    echo "$x"
done

echo "configuring certbot"
echo "setting with main domain ${domainsArr[0]}"

echo "reloading haproxy"
sudo service haproxy restart
