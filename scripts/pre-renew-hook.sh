#!/usr/bin/env bash

# Renew the certificate
certbot renew --force-renewal --tls-sni-01-port=8888
