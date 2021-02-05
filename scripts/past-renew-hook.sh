#!/usr/bin/env bash
pm2 restart all --update-env
pm2 save
bash -c "cat /etc/letsencrypt/live/{{mainDomain}}/fullchain.pem /etc/letsencrypt/live/{{mainDomain}}/privkey.pem > /etc/ssl/haproxycert/haproxy.pem"
service haproxy restart
