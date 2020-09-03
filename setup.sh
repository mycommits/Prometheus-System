#!/usr/bin/env bash
# Maintainer Mohammad Hosein Chahardoli <mohammadhoseinchahardoli@gmail.com>
function prometheus_install() {
    sudo useradd -M -r -s /bin/false prometheus
    sudo mkdir -p {/etc/prometheus,/var/lib/prometheus}
    sudo chown prometheus:prometheus /var/lib/prometheus
    cd /tmp
    wget https://github.com/prometheus/prometheus/releases/download/v2.20.1/prometheus-2.20.1.linux-amd64.tar.gz
    tar xzvf prometheus-2.20.1.linux-amd64.tar.gz
    cd prometheus-2.20.1.linux-amd64
    sudo mv {consoles,console_libraries,prometheus.yml} /etc/prometheus
    sudo chown -R prometheus:prometheus /etc/prometheus
    sudo mv {prometheus,promtool} /usr/local/bin/
    sudo chown prometheus:prometheus /usr/local/bin/{prometheus,promtool}
    cat << EOF > prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF
    sudo mv prometheus.service /etc/systemd/system/prometheus.service
    sudo chown root:root /etc/systemd/system/prometheus.service
    sudo systemctl daemon-reload
    sudo systemctl enable --now prometheus
    sudo rm -rf /tmp/{prometheus-2.20.1.linux-amd64.tar.gz,prometheus-2.20.1.linux-amd64}
}
function alertmanager_install() {
    sudo useradd -M -r -s /bin/false alertmanager
    sudo mkdir /etc/alertmanager
    cd /tmp/
    wget https://github.com/prometheus/alertmanager/releases/download/v0.21.0/alertmanager-0.21.0.linux-amd64.tar.gz
    tar xzvf alertmanager-0.21.0.linux-amd64.tar.gz
    cd alertmanager-0.21.0.linux-amd64/
    sudo mv {alertmanager,amtool} /usr/local/bin/
    sudo chown alertmanager:alertmanager /usr/local/bin/{alertmanager,amtool}
    sudo mv alertmanager.yml /etc/alertmanager/
    sudo chown -R alertmanager:alertmanager /etc/alertmanager/
    cat << EOF > alertmanager.service
[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
WorkingDirectory=/etc/alertmanager/
ExecStart=/usr/local/bin/alertmanager \
    --config.file=/etc/alertmanager/alertmanager.yml
[Install]
WantedBy=multi-user.target
EOF
    sudo mv alertmanager.service /etc/systemd/system/alertmanager.service
    sudo chown root:root /etc/systemd/system/alertmanager.service
    sudo systemctl daemon-reload
    sudo systemctl enable --now alertmanager
    sudo mkdir /etc/amtool
    cat << EOF > config.yml
alertmanager.url: http://localhost:9093
EOF
    sudo mv config.yml /etc/amtool/config.yml
    sudo chown root:root /etc/amtool/config.yml
    sleep 2
    amtool config show
    sudo rm -rf /tmp/{alertmanager-0.21.0.linux-amd64.tar.gz,alertmanager-0.21.0.linux-amd64/}
}
function grafana_install() {
    sudo yum install -y https://dl.grafana.com/oss/release/grafana-7.1.3-1.x86_64.rpm
    sudo systemctl enable --now grafana-server
}
function nodeexporter_install() {
    sudo useradd -M -r -s /bin/false node_exporter
    cd /tmp/
    wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
    tar -xvf node_exporter-1.0.1.linux-amd64.tar.gz
    cd node_exporter-1.0.1.linux-amd64
    sudo mv node_exporter /usr/local/bin/
    sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
    cat << EOF > node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF
    sudo mv node_exporter.service /etc/systemd/system/node_exporter.service
    sudo chown root:root /etc/systemd/system/node_exporter.service
    sudo systemctl daemon-reload
    sudo systemctl enable --now node_exporter
    sudo rm -rf /tmp/{node_exporter-1.0.1.linux-amd64.tar.gz,node_exporter-1.0.1.linux-amd64}
}
function apacheexporter_install() {
    sudo useradd -M -r -s /bin/false apache_exporter
    cd /tmp/
    wget https://github.com/Lusitaniae/apache_exporter/releases/download/v0.7.0/apache_exporter-0.7.0.linux-amd64.tar.gz
    tar xvfz apache_exporter-0.7.0.linux-amd64.tar.gz
    cd apache_exporter-0.7.0.linux-amd64
    sudo mv apache_exporter /usr/local/bin/
    sudo chown apache_exporter:apache_exporter /usr/local/bin/apache_exporter
    cat << EOF > apache_exporter.service

[Unit]
Description=Prometheus Apache Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=apache_exporter
Group=apache_exporter
Type=simple
ExecStart=/usr/local/bin/apache_exporter

[Install]
WantedBy=multi-user.target
EOF
    sudo mv apache_exporter.service /etc/systemd/system/apache_exporter.service
    sudo chown root:root /etc/systemd/system/apache_exporter.service
    sudo systemctl daemon-reload
    sudo systemctl enable --now apache_exporter
    sudo rm -rf /tmp/{apache_exporter-0.7.0.linux-amd64.tar.gz,apache_exporter-0.7.0.linux-amd64}
}
function pushgateway_install() {
    sudo useradd -M -r -s /bin/false pushgateway
    cd /tmp/
    wget https://github.com/prometheus/pushgateway/releases/download/v1.2.0/pushgateway-1.2.0.linux-amd64.tar.gz
    tar xvfz pushgateway-1.2.0.linux-amd64.tar.gz
    cd pushgateway-1.2.0.linux-amd64/
    sudo cp pushgateway /usr/local/bin/
    sudo chown pushgateway:pushgateway /usr/local/bin/pushgateway
    cat << EOF > pushgateway.service
[Unit]
Description=Prometheus Pushgateway
Wants=network-online.target
After=network-online.target

[Service]
User=pushgateway
Group=pushgateway
Type=simple
ExecStart=/usr/local/bin/pushgateway

[Install]
WantedBy=multi-user.target
EOF
    sudo mv pushgateway.service /etc/systemd/system/pushgateway.service
    sudo chown root:root /etc/systemd/system/pushgateway.service
    sudo systemctl daemon-reload
    sudo systemctl enable --now pushgateway.service
    sudo rm -rf /tmp/{pushgateway-1.2.0.linux-amd64.tar.gz,pushgateway-1.2.0.linux-amd64/}
}