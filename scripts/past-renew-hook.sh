#!/usr/bin/env bash
{{pm2path}} restart all --update-env
{{pm2path}} save
bash -c "cat /etc/letsencrypt/live/{{mainDomain}}/fullchain.pem /etc/letsencrypt/live/{{mainDomain}}/privkey.pem > /etc/ssl/haproxycert/haproxy.pem"
service haproxy restart
