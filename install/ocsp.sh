#!/bin/bash

cd /etc/ssl/example/
while true; do
    openssl ocsp -index rootCA/ca_files/index.txt -port 82 -CA rootCA/certs/ca.crt -text -rsigner rootCA/certs/ocsp.crt -rkey rootCA/private/ocsp.key
    openssl ocsp -index webCA/ca_files/index.txt -port 83 -CA webCA/certs/ca.crt -text -rsigner webCA/certs/ocsp.crt -rkey webCA/private/ocsp.key
    sleep 1
done

