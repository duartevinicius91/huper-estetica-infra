mkdir -p /opt/nomad/data
cp nomad.service /etc/systemd/system/
systemctl daemon-reload
systemctl status nomad
systemctl enable nomad
systemctl status nomad
systemctl start nomad
systemctl status nomad
export NOMAD_ADDR="http://$(dig -x $(curl -s ifconfig.me) +short | sed 's/\.$//'):4646"