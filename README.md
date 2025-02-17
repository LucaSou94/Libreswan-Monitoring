# Libreswan-Monitoring
Script e configurazioni per monitorare LibreSwan con Prometheus e Grafana.

Descrizione
Il progetto ha l'obiettivo di monitorare le connessioni IPsec gestite da LibreSwan, utilizzando node_exporter per raccogliere metriche personalizzate, Prometheus per raccogliere e memorizzare le metriche, e Grafana per visualizzare le metriche in una dashboard interattiva.

## Prerequisiti

- Rocky Linux o una distribuzione equivalente
- LibreSwan installato
- Node Exporter installato
- Prometheus installato
- Grafana installato

### 1. Installazione di LibreSwan

1) Installa LibreSwan sulla VM Rocky Linux: 
   dnf install libreswan-4.15-3.el9.x86_64

### 2. Installazione di Node Exporter
   
1) Scarica e Installa Node Exporter:
   wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
   tar xvfz node_exporter-1.3.1.linux-amd64.tar.gz
   sudo mv node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/

2) Creazione del Servizio Systemd per Node Exporter:
   vim /etc/systemd/system/node_exporter.service

[Unit]
Description=Node Exporter
Wants=network-online.target
After=network.online.target

[Service]
ExecStart=/usr/local/bin/node_exporter --collector.textfile.directory=/var/lib/node_exporter/textfile_collector
restart=always
RestartSec=10

[Install]
WantedBy=default.target

3) Avviare e Abilitare Node Exporter:
   sudo systemctl daemon-reload
   sudo systemctl start node_exporter
   sudo systemctl enable node_exporter

### 3. Creazione dello Script per la Metrica Personalizzata

1) Creare uno script che verifichi lo stato delle connessioni LibreSwan e generi una metrica personalizzata.

#!/bin/bash

 script che verifica lo stato delle connessioni IPsec
status=$(ipsec whack --status)

 Verifica lo stato delle connessioni
if [[ $status == *"INSTALLED"* ]]; then
  echo "libreswan_connection_active 1" > /var/lib/node_exporter/textfile_collector/libreswan_status.prom
else
  echo "libreswan_connection_active 0" > /var/lib/node_exporter/textfile_collector/libreswan_status.prom
fi

2) Rendere eseguibile lo script:
   chmod +x /root/libreswan_status.sh

###  4. Configurazione di Crontab per Eseguire lo Script Periodicamente

crontab -e

* * * * * /percoso_script/libreswan_status.sh

### 5. Installazione e Configurazione di Prometheus

1) Scarica e Installa Prometheus:
   wget https://github.com/prometheus/prometheus/releases/download/v2.31.1/prometheus-2.31.1.linux-amd64.tar.gz
   tar xvfz prometheus-2.31.1.linux-amd64.tar.gz
   mv prometheus-2.31.1.linux-amd64 /usr/local/bin/prometheus
   mkdir /etc/prometheus
   mkdir /var/lib/prometheus

2) Configurazione di Prometheus:

vim /etc/prometheus/prometheus.yml

global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
   
3) Creazione del Servizio Systemd per Prometheus:


[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
--config.file=/etc/prometheus/prometheus.yml \
--storage.tsdb.path=/var/lib/prometheus/ \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target

4) Avviare e Abilitare Prometheus
   systemctl daemon-reload
   systemctl start prometheus
   systemctl enable prometheus

### 6. Configurazione di Grafana

1) Aggiungere un datasource Prometheus che punti al server: 
   http://IP-Server:9090

2) Creare una nuova dashboard e configurare il pannello:
   Nel campo Query, inserire libreswan_connection_active









       



