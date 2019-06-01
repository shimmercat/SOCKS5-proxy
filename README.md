# socks5-tc

# Optional
Run setup.sh to create the needed networks, subnets and firewall configs. 
For simplicity they have fixed ranges and are limited to us-east1 but extending it will not be a problem.

It's strongly recommended to limit the source ip addresses or ranges that can access port 1080/tcp.

# Create instance

Run "create-vm.sh INSTANCE_NAME" to create a VM named INSTANCE_NAME. 
For simplicity, the script asumes f1-micro machine-type but it can be any other.

# Startup Script
startup-script.sh
Configures all the necessary, starts a SOCKS5 proxy in port 1080/tcp and applies the traffic control settings in the ingress interface.
