#!/bin/bash

# script che verifica lo stato delle connessioni IPsec
status=$(ipsec whack --status)

# Verifica lo stato delle connessioni
if [[ $status == *"INSTALLED"* ]]; then
  echo "libreswan_connection_active 1" > /var/lib/node_exporter/textfile_collector/libreswan_status.prom
else
  echo "libreswan_connection_active 0" > /var/lib/node_exporter/textfile_collector/libreswan_status.prom
fi

