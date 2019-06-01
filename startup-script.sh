#! /bin/bash
echo -e "Configuring socks proxy"

# Get seconary interface IP and GW
IP_ETH1=$(ip -br addr show eth1 | awk '{print substr($3,1,index($3,"/")-1);}')
ROUTE_ETH1=$(ip route | grep 'via.*eth1' | awk '{ print $3 }')

# Optional
# yum update -y

# Open port 1080 in FW
firewall-cmd --add-port 1080/tcp --permanent
firewall-cmd --reload

# Tune net params
cat <<EOF >> /etc/sysctl.conf
net.ipv4.ip_forward = 1
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.default.send_redirects=0
net.ipv4.tcp_keepalive_time = 1800
net.ipv4.tcp_keepalive_intvl = 600
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_max_syn_backlog = 3000
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 87380 16777216

net.core.somaxconn = 5000
net.core.netdev_max_backlog = 2000
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.rmem_default = 16777216
net.core.wmem_default = 16777216
net.core.optmem_max = 40960
EOF
sysctl -p

# Add policy routing
echo default table 200 via $ROUTE_ETH1 > /etc/sysconfig/network-scripts/route-eth1
echo from $IP_ETH1 table 200 > /etc/sysconfig/network-scripts/rule-eth1
systemctl restart network

# Add system user to allow SSH to localhost and publish dynamic port forwarding
useradd socks -r -m -s /sbin/nologin
sudo -u socks ssh-keygen -q -f /home/socks/.ssh/id_rsa -N ""
cat /home/socks/.ssh/id_rsa.pub >> /home/socks/.ssh/authorized_keys
chown socks.socks /home/socks/.ssh/authorized_keys
chmod 600 /home/socks/.ssh/authorized_keys

sudo -u socks ssh -o StrictHostKeyChecking=no -f -N -D $IP_ETH1:1080 localhost

# Traffic control settings
tc qdisc add dev eth1 root tbf rate 1mbit burst 32kbit latency 400ms

# https://wiki.linuxfoundation.org/networking/netem
# tc qdisc add dev eth1 root netem delay 100ms 20ms distribution normal
# tc qdisc change dev eth1 root netem loss 0.3% 25%

# tc qdisc add dev eth1 root handle 1:0 netem delay 100ms
# tc qdisc add dev eth1 parent 1:1 handle 10: tbf rate 256kbit buffer 1600 limit 3000

# tc -s qdisc ls dev eth1

