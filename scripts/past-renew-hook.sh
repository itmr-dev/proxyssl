#!/usr/bin/env bash
echo "getting env"
source ~/.bashrc

echo "restarting pm2"
{{pm2path}} restart all --update-env
{{pm2path}} save

echo "creating proxy certificate"
bash -c "cat /etc/letsencrypt/live/{{mainDomain}}/fullchain.pem /etc/letsencrypt/live/{{mainDomain}}/privkey.pem > /etc/ssl/haproxycert/haproxy.pem"

echo "restarting proxy"
service haproxy restart
