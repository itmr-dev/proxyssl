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
echo " |___/___/_| .__/|_|  \___/_/\_\\__, |     |___/\___|\__|\__,_| .__/       v2.2.2";
echo "           |_|                  |___/                         |_|    ";

echo "";
echo "";

read -p "Press [Enter] key to start setup..."

echo "";
echo "";

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
sudo snap set certbot trust-plugin-with-root=ok
sudo snap install certbot-dns-cloudflare

echo "installing haproxy"
apt-get -y install wget vim haproxy

echo "installing nvm"
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash

echo "reloading bash"
source ~/.bashrc

echo "setting up nvm"
nvm install --lts
# nvm use 13

echo "installing pm2"
npm i -g pm2

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
echo "dns_cloudflare_api_token = ${cloudflareToken}" > /opt/.secrets/certbot/cloudflare.ini

echo "restricting cloudflare token file access"
chmod 600 /opt/.secrets/certbot/cloudflare.ini

echo "recieved following domains:"
domainsArr=($domains)
mainDomain=${domainsArr[0]}
cerbotCmd="sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials /opt/.secrets/certbot/cloudflare.ini --email ${certbotMail} --agree-tos"
for x in "${domainsArr[@]}"
do
    echo "$x"
    cerbotCmd+=" -d $x"
done

echo "export CERTS_DIR=\"/etc/letsencrypt/live/${mainDomain}/\"" >> ~/.bashrc

echo "creating cerbot deploy script with domains"
cat ./scripts/past-renew-hook.sh | mo > /opt/past-renew-hook.sh

echo "copying certbot scripts"
sudo cp ./scripts/pre-renew-hook.sh /opt/

echo "configuring certbot"
echo "setting up with main domain ${mainDomain}"
$cerbotCmd

echo "reloading haproxy"
sudo service haproxy restart

echo "To make sure all your backends are getting started on boot please follow those steps:"
pm2 startup

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