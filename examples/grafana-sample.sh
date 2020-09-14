# Install some required packages:
sudo apt-get install -y apt-transport-https software-properties-common wget

# Add the GPG key for the Grafana OSS repository, and then add the repository:
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

# Install the Grafana package:
sudo apt-get update
sudo apt-get install grafana=6.6.2

# Enable and start the grafana-server service:
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# Make sure the service is in the Active (running) state:
sudo systemctl status grafana-server

# You can also verify Grafana is working by accessing it in a web browser at http://<GRAFANA_SERVER_PUBLIC_IP>:3000.
