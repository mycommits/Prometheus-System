# Prometheus
## Installation
1.Create a system user for Prometheus:
```
sudo useradd --no-create-home --shell /bin/false prometheus
```
2.Create the directories in which we'll be storing our configuration files and libraries:
```
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
```
3.Set the ownership of the /var/lib/prometheus directory:
```
sudo chown prometheus:prometheus /var/lib/prometheus
```
4.Pull down the tar.gz file from the [Prometheus downloads page:](https://prometheus.io/download/)
```
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.20.1/prometheus-2.20.1.linux-amd64.tar.gz
```
5.Extract the files:
```
tar xzvf prometheus-2.20.1.linux-amd64.tar.gz
```
6.Move the configuration file and set the owner to the prometheus user:
```
cd prometheus-2.20.1.linux-amd64
sudo mv console* /etc/prometheus
sudo mv prometheus.yml /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus
```
7.Move the binaries and set the owner:
```
sudo mv prometheus /usr/local/bin/
sudo mv promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
```
8.Create the [service file](./prometheus.service):
```
sudo vim /etc/systemd/system/prometheus.service
```
9.Reload systemd:
```
sudo systemctl daemon-reload
```
10.Start Prometheus, and make sure it automatically starts on boot:
```
sudo systemctl start prometheus
sudo systemctl enable prometheus
```
11.Visit Prometheus in your web browser at YourIP:9090.

# Alert Manager
## Installation
1.Create the alertmanager system user:
```
sudo useradd --no-create-home --shell /bin/false alertmanager
```
2.Create the /etc/alertmanager directory:
```
sudo mkdir /etc/alertmanager
```
3.Download Alertmanager from the [Prometheus downloads page:](https://prometheus.io/download/)
```
cd /tmp/
wget https://github.com/prometheus/alertmanager/releases/download/v0.21.0/alertmanager-0.21.0.linux-amd64.tar.gz
```
4.Extract the files:
```
tar xzvf alertmanager-0.21.0.linux-amd64.tar.gz
```
5.Move the binaries:
```
cd alertmanager-0.21.0.linux-amd64/
sudo mv alertmanager /usr/local/bin/
sudo mv amtool /usr/local/bin/
```
6.Set the ownership of the binaries:
```
sudo chown alertmanager:alertmanager /usr/local/bin/alertmanager
sudo chown alertmanager:alertmanager /usr/local/bin/amtool
```
7.Move the configuration file into the /etc/alertmanager directory:
```
sudo mv alertmanager.yml /etc/alertmanager/
```
8.Set the ownership of the /etc/alertmanager directory:
```
sudo chown -R alertmanager:alertmanager /etc/alertmanager/
```
9.Create the [alertmanager.service](./alertmanager.service) file for systemd:
```
sudo vim /etc/systemd/system/alertmanager.service
```
10.Stop Prometheus, and then update the Prometheus configuration file to use Alertmanager:
```
sudo systemctl stop prometheus
sudo vim /etc/prometheus/prometheus.yml

alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - localhost:9093
```
11.Reload systemd, and then start the prometheus and alertmanager services:
```
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl start alertmanager
```
12.Make sure alertmanager starts on boot:
```
sudo systemctl enable alertmanager
```
13.Visit YourIP:9093 in your browser to confirm Alertmanager is working.

# Grafana
## Installation
1.Download Grafana RPM file from the [Grafana downloads page:](https://grafana.com/grafana/download)
```
wget https://dl.grafana.com/oss/release/grafana-7.1.3-1.x86_64.rpm
```
2. Install the RPM
```
sudo yum install -y grafana-7.1.3-1.x86_64.rpm
```
3. Make sure Grafana starts on boot:
```
sudo systemctl enable --now grafana-server
``` 
4.Access Grafana's web UI by going to YourIP:3000.

# Node Exporter
## Installation
1.Create a system user:
```
sudo useradd --no-create-home --shell /bin/false node_exporter
```
2.Download the Node Exporter from [Prometheus downloads page:](https://prometheus.io/download/)
```
cd /tmp/
wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
```
3.Extract its contents; note that the versioning of the Node Exporter may be different:
```
tar -xvf node_exporter-1.0.1.linux-amd64.tar.gz
```
4.Move into the newly created directory:
```
cd node_exporter-1.0.1.linux-amd64
```
5.Move the provided binary:
```
sudo mv node_exporter /usr/local/bin/
```
6.Set the ownership:
```
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
```
7.Create a systemd [service file:](./node_exporter.service)
```
sudo vim /etc/systemd/system/node_exporter.service
```
8.Start the Node Exporter:
```
sudo systemctl daemon-reload
sudo systemctl start node_exporter
```
9.Add the endpoint to the Prometheus configuration file:
```
sudo vim /etc/prometheus/prometheus.yml

- job_name: 'nodeexporter'
  static_configs:
  - targets: ['localhost:9100']
```
10.Restart Prometheus:
```
sudo systemctl restart prometheus
```
## Stress Test
1.Navigate to the Prometheus web UI.
Using the expression editor, search for cpu, meminfo, and related system terms to view the newly added metrics.

2.Search for node_memory_MemFree_bytes in the expression editor;
shorten the time span for the graph to be about 30 minutes of data.

3. Install the stress utility
```
sudo yum install -y stress
```
4. Test memory
```
stress -m 2
```
5. Test CPU
```
stress -c 5
```
6. Test Disk
```
stress -i 40
```
# Google cAdvisor
## Installation
1. Launch the Google cAdvisor:
```
sudo docker run \
   --volume=/:/rootfs:ro \
   --volume=/var/run:/var/run:ro \
   --volume=/sys:/sys:ro \
   --volume=/var/lib/docker/:/var/lib/docker:ro \
   --volume=/dev/disk/:/dev/disk:ro \
   --publish=8000:8080 \
   --detach=true \
   --name=cadvisor \
   google/cadvisor:latest
```
2. List available containers to confirm it's working:
```
sudo docker container ls
```
3.Update the Prometheus config:
```
sudo vim /etc/prometheus/prometheus.yml

   - job_name: 'cadvisor'
     static_configs:
     - targets: ['localhost:8000']
```
4.Restart Prometheus:
```
sudo systemctl restart prometheus
```
