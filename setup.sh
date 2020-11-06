#!/usr/bin/env bash
# Maintainer Mohammad Hosein Chahardoli <mohammadhoseinchahardoli@gmail.com>
wget -h 1>/dev/null 2>&1 || yum install -y wget
function prometheus_install() {
    sudo useradd --no-create-home --disabled-login --shell /bin/false --gecos "Prometheus Monitoring User" --system prometheus
    sudo mkdir -p {/etc/prometheus,/var/lib/prometheus}
    sudo chown prometheus:prometheus /var/lib/prometheus
    cd /tmp
    VERSION=$(curl https://raw.githubusercontent.com/prometheus/prometheus/master/VERSION)
    wget https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.linux-amd64.tar.gz
    tar xvzf prometheus-${VERSION}.linux-amd64.tar.gz
    cd prometheus-${VERSION}.linux-amd64
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
    sudo rm -rf /tmp/{prometheus-${VERSION}.linux-amd64.tar.gz,prometheus-${VERSION}.linux-amd64}
    firewall-cmd --add-port=9090/tcp --permanent || echo -e "\nfirewall-cmd not available!\nPlease configure linux firewall manually." && firewall-cmd --reload
    echo -e "\nThis script doesn't configure SElinux. Please configure SElinux manually."
}
function alertmanager_install() {
    sudo useradd --no-create-home --disabled-login --shell /bin/false --gecos "Alertmanager User" --system alertmanager
    sudo mkdir /etc/alertmanager
    cd /tmp/
    VERSION=$(curl https://raw.githubusercontent.com/prometheus/alertmanager/master/VERSION)
    wget https://github.com/prometheus/alertmanager/releases/download/v${VERSION}/alertmanager-${VERSION}.linux-amd64.tar.gz
    tar xvzf alertmanager-${VERSION}.linux-amd64.tar.gz
    cd alertmanager-${VERSION}.linux-amd64
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
    sudo rm -rf /tmp/{alertmanager-${VERSION}.linux-amd64.tar.gz,alertmanager-${VERSION}.linux-amd64}
    firewall-cmd --add-port=9093/tcp --permanent || echo -e "\nfirewall-cmd not available!\nPlease configure linux firewall manually." && firewall-cmd --reload
    echo -e "\nThis script doesn't configure SElinux. Please configure SElinux manually."
}
function grafana_install() {
    cat << EOF > /etc/yum/repos.d/grafana.repo
[grafana]
 name=grafana
 baseurl=https://packagecloud.io/grafana/stable/el/7/$basearch
 repo_gpgcheck=1
 enabled=1
 gpgcheck=1
 gpgkey=https://packagecloud.io/gpg.key https://grafanarel.s3.amazonaws.com/RPM-GPG-KEY-grafana
 sslverify=1
 sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF
    sudo yum install -y grafana
    sudo systemctl daemon-reload
    sudo systemctl enable --now grafana-server
    firewall-cmd --add-port=3000/tcp --permanent || echo -e "\nfirewall-cmd not available!\nPlease configure linux firewall manually." && firewall-cmd --reload
    echo -e "\nThis script doesn't configure SElinux. Please configure SElinux manually."
}
function nodeexporter_install() {
    sudo useradd --no-create-home --disabled-login --shell /bin/false --gecos "Node Exporter User" --system node_exporter
    cd /tmp/
    VERSION=$(curl https://raw.githubusercontent.com/prometheus/node_exporter/master/VERSION)
    wget https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.linux-amd64.tar.gz
    tar xvzf node_exporter-${VERSION}.linux-amd64.tar.gz
    cd node_exporter-${VERSION}.linux-amd64
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
    sudo rm -rf /tmp/{node_exporter-${VERSION}.linux-amd64.tar.gz,node_exporter-${VERSION}.linux-amd64}
    firewall-cmd --add-port=9100/tcp --permanent || echo -e "\nfirewall-cmd not available!\nPlease configure linux firewall manually." && firewall-cmd --reload
    echo -e "\nThis script doesn't configure SElinux. Please configure SElinux manually."
}
function apacheexporter_install() {
    sudo useradd --no-create-home --disabled-login --shell /bin/false --gecos "Apache Exporter User" --system apache_exporter
    cd /tmp/
    VERSION=$(curl https://raw.githubusercontent.com/Lusitaniae/apache_exporter/master/VERSION)
    wget https://github.com/Lusitaniae/apache_exporter/releases/download/v${VERSION}/apache_exporter-${VERSION}.linux-amd64.tar.gz
    tar xvfz apache_exporter-${VERSION}.linux-amd64.tar.gz
    cd apache_exporter-${VERSION}.linux-amd64
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
    sudo rm -rf /tmp/{apache_exporter-${VERSION}.linux-amd64.tar.gz,apache_exporter-${VERSION}.linux-amd64}
    firewall-cmd --add-port=9117/tcp --permanent || echo -e "\nfirewall-cmd not available!\nPlease configure linux firewall manually." && firewall-cmd --reload
    echo -e "\nThis script doesn't configure SElinux. Please configure SElinux manually."
}
function pushgateway_install() {
    sudo useradd --no-create-home --disabled-login --shell /bin/false --gecos "Push Gateway User" --system pushgateway
    cd /tmp/
    VERSION=$(curl https://raw.githubusercontent.com/prometheus/pushgateway/master/VERSION)
    wget https://github.com/prometheus/pushgateway/releases/download/v${VERSION}/pushgateway-${VERSION}.linux-amd64.tar.gz
    tar xvzf pushgateway-${VERSION}.linux-amd64.tar.gz
    cd pushgateway-${VERSION}.linux-amd64
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
    sudo rm -rf /tmp/{pushgateway-${VERSION}.linux-amd64.tar.gz,pushgateway-${VERSION}.linux-amd64/}
    firewall-cmd --add-port=9091/tcp --permanent || echo -e "\nfirewall-cmd not available!\nPlease configure linux firewall manually." && firewall-cmd --reload
    echo -e "\nThis script doesn't configure SElinux. Please configure SElinux manually."
}
