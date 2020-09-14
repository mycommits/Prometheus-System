# Install Apache:
sudo apt-get update
sudo apt-get install -y apache2

# Make a request to Apache to verify it is up and running:
curl localhost:80

# Download and install the Apache Exporter binary:
sudo useradd -M -r -s /bin/false apache_exporter
wget https://github.com/Lusitaniae/apache_exporter/releases/download/v0.7.0/apache_exporter-0.7.0.linux-amd64.tar.gz
tar xvfz apache_exporter-0.7.0.linux-amd64.tar.gz
sudo cp apache_exporter-0.7.0.linux-amd64/apache_exporter /usr/local/bin/
sudo chown apache_exporter:apache_exporter /usr/local/bin/apache_exporter

# Set up a systemd service for Apache Exporter:
sudo cat << EOF > /etc/systemd/system/apache_exporter.service

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

# Start and enable the apache_exporter service:
sudo systemctl enable apache_exporter
sudo systemctl start apache_exporter

# Make sure Apache Exporter is working:
sudo systemctl status apache_exporter
curl localhost:9117/metrics

# Configure Prometheus to Scrape Metrics from Apache
## Log in to your Prometheus server.
### Edit the Prometheus config:
sudo vi /etc/prometheus/prometheus.yml

#### Under the scrape_configs section, add a scrape configuration for the Apache Exporter. Use the private IP address of your Linux/Apache server for the target:
- job_name: 'Apache'
    static_configs:
    - targets: ['<APACHE_SERVER_PRIVATE_IP>:9117']

# Restart Prometheus to load the new configuration:
sudo systemctl restart prometheus

# Use the expression browser to verify you can see Apache metrics in Prometheus. You can access the expression browser in a web browser at http://<PROMETHEUS_SERVER_PUBLIC_IP>:9090.
# Run a query to view some Apache metric data:
## apache_workers