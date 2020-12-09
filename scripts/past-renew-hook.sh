#!/usr/bin/env bash
pm2 restart all --update-env
pm2 save
bash -c "cat /etc/letsencrypt/live/*/fullchain.pem /etc/letsencrypt/live/*/privkey.pem > /etc/ssl/haproxycert/haproxy.pem"
service haproxy reload
