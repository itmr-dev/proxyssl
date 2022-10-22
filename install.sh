#!/usr/bin/env bash

echo "                                                                                             ";
echo "88                                                              88                           ";
echo "\"\"    ,d                                                        88                           ";
echo "      88                                                        88                           ";
echo "88  MM88MMM  88,dPYba,,adPYba,   8b,dPPYba,             ,adPPYb,88   ,adPPYba,  8b       d8  ";
echo "88    88     88P'   \"88\"    \"8a  88P'   \"Y8  aaaaaaaa  a8\"    \`Y88  a8P_____88  \`8b     d8'  ";
echo "88    88     88      88      88  88          \"\"\"\"\"\"\"\"  8b       88  8PP\"\"\"\"\"\"\"   \`8b   d8'   ";
echo "88    88,    88      88      88  88                    \"8a,   ,d88  \"8b,   ,aa    \`8b,d8'    ";
echo "88    \"Y888  88      88      88  88                     \`\"8bbdP\"Y8   \`\"Ybbd8\"'      \"8\"      ";

echo ""

echo "  ___ ___| |_ __  _ __ _____  ___   _       ___  ___| |_ _   _ _ __  ";
echo " / __/ __| | '_ \| '__/ _ \ \/ / | | |_____/ __|/ _ \ __| | | | '_ \ ";
echo " \__ \__ \ | |_) | | | (_) >  <| |_| |_____\__ \  __/ |_| |_| | |_) |";
echo " |___/___/_| .__/|_|  \___/_/\_\\__, |     |___/\___|\__|\__,_| .__/       v2.3.3";
echo "           |_|                  |___/                         |_|    ";

echo "";
echo "";

read -p "Press [Enter] key to start setup..."

echo "";
echo "";

echo "Beginning proxyssl setup"

echo "updating system"
sudo apt update && sudo apt upgrade -y

echo "installing cron"
sudo apt install cron -y

echo "installing certbot, pip3 & cloudflare-plugin"
sudo apt update
sudo apt install certbot python3-pip -y
sudo pip3 install certbot-dns-cloudflare

echo "installing wget, vim, haproxy, rsync"
sudo apt -y install wget vim haproxy rsync

echo "installing nvm"
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

echo "reloading bash"
source ~/.bashrc
echo "load nvm"
source ~/.nvm/nvm.sh

echo "setting up nvm"
nvm install --lts
# nvm use 13

echo "installing pm2"
npm i -g pm2

echo "installing yarn"
npm i -g yarn

echo "reloading bash"
source ~/.bashrc

echo "getting pm2 path"
pm2path=$(command -v pm2)

echo "removing standard configs & scripts"
sudo rm /etc/letsencrypt/cli.ini
sudo rm /etc/cron.d/cerbot
sudo rm /etc/haproxy/haproxy.cfg

echo "creating letsencrypt folder"
sudo mkdir -p /etc/letsencrypt
sudo mkdir -p /etc/ssl/haproxycert

echo "creating secrets folder"
sudo mkdir -p /opt/.secrets/certbot/

echo "creating cloudflare token file"
sudo touch /opt/.secrets/certbot/cloudflare.ini

echo "change secrets folder owner"
sudo chown -R $USER /opt/.secrets/

echo "restricting cloudflare token file access"
sudo chmod 600 /opt/.secrets/certbot/cloudflare.ini

echo "copying new configs & scripts"
sudo cp ./configs/certbot /etc/cron.d/
sudo cp ./configs/cli.ini /etc/letsencrypt/
sudo cp ./configs/haproxy.cfg /etc/haproxy/

echo "installing mustache"
curl -sSL https://git.io/get-mo -o mo
. "./mo"
echo "Mustache was installed successfully" | mo

echo ""
read -p 'which email do you want to use for ssl certificates? > ' certbotMail
read -p 'which domains should be configured? (seperated by spaces) > ' domains

echo ""
echo "Setting up Cloudflare Certbot API"
echo "Please create a restricted token with the \"Zone:DNS:Edit\" permissions"
read -p 'please provide your cloudflare token > ' cloudflareToken

echo "saving token to ~/.secrets/certbot/cloudflare.ini"
sudo echo "dns_cloudflare_api_token = ${cloudflareToken}" > /opt/.secrets/certbot/cloudflare.ini

echo "recieved following domains:"
domainsArr=($domains)
mainDomain=${domainsArr[0]}
cerbotCmd="sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials /opt/.secrets/certbot/cloudflare.ini --dns-cloudflare-propagation-seconds 30 --email ${certbotMail} --agree-tos"
for x in "${domainsArr[@]}"
do
    echo "$x"
    cerbotCmd+=" -d $x"
done

echo "export CERTS_DIR=\"/etc/letsencrypt/live/${mainDomain}/\"" >> ~/.bashrc

echo "creating past renew hook"
sudo touch /opt/past-renew-hook.sh

echo "change past renew hook owner"
sudo chown $USER /opt/past-renew-hook.sh

echo "creating cerbot deploy script with domains"
sudo cat ./scripts/past-renew-hook.sh | mo > /opt/past-renew-hook.sh

echo "copying certbot scripts"
sudo cp ./scripts/pre-renew-hook.sh /opt/

echo "change pre renew hook owner"
sudo chown $USER /opt/pre-renew-hook.sh

echo "configuring certbot"
echo "setting up with main domain ${mainDomain}"
$cerbotCmd

echo "reloading haproxy"
sudo service haproxy restart

echo "To make sure all your backends are getting started on boot please follow those steps:"
pm2 startup

echo "Generating ssh-key for GitHub actions"
mkdir -p ~/.ssh/
ssh-keygen -m PEM -t rsa -b 4096 -f ~/.ssh/github-actions
touch ~/.ssh/authorized_keys
cat ~/.ssh/github-actions.pub >> ~/.ssh/authorized_keys

echo ""
echo ""
echo ""

echo "                                                                                             ";
echo "88                                                              88                           ";
echo "\"\"    ,d                                                        88                           ";
echo "      88                                                        88                           ";
echo "88  MM88MMM  88,dPYba,,adPYba,   8b,dPPYba,             ,adPPYb,88   ,adPPYba,  8b       d8  ";
echo "88    88     88P'   \"88\"    \"8a  88P'   \"Y8  aaaaaaaa  a8\"    \`Y88  a8P_____88  \`8b     d8'  ";
echo "88    88     88      88      88  88          \"\"\"\"\"\"\"\"  8b       88  8PP\"\"\"\"\"\"\"   \`8b   d8'   ";
echo "88    88,    88      88      88  88                    \"8a,   ,d88  \"8b,   ,aa    \`8b,d8'    ";
echo "88    \"Y888  88      88      88  88                     \`\"8bbdP\"Y8   \`\"Ybbd8\"'      \"8\"      ";

echo ""

echo "  ___ ___| |_ __  _ __ _____  ___   _       ___  ___| |_ _   _ _ __  ";
echo " / __/ __| | '_ \| '__/ _ \ \/ / | | |_____/ __|/ _ \ __| | | | '_ \ ";
echo " \__ \__ \ | |_) | | | (_) >  <| |_| |_____\__ \  __/ |_| |_| | |_) |";
echo " |___/___/_| .__/|_|  \___/_/\_\\__, |     |___/\___|\__|\__,_| .__/ ";
echo "           |_|                  |___/                         |_|    ";

echo ""
echo "Install and setup is done. Check for any errors above."
echo "Use env var \$CERTS_DIR in your backends to use outgoing ssl and firewall rules or use the proxy to expose your backends."
echo "Use \"sudo certbot renew --dry-run\" verify the certbot configuration."
echo ""
echo "Please also be aware that changing your default node version will also require you to change the deploy hooks for pm2 restart to work."
echo ""
echo ""
echo "Use the following command to view the ssh private key for rsync GitHub action deployments:"
echo "cat ~/.ssh/github-actions"
echo ""
