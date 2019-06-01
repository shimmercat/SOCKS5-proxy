#! /bin/bash

# Create egress network
gcloud compute networks create egress-network \
    --subnet-mode=custom \
    --bgp-routing-mode=regional

# Create egress subnet
gcloud compute networks subnets create egress \
    --network=egress-network \
    --range=192.168.0.0/24 \
    --region=us-east1

# Create ingress network
gcloud compute networks create ingress-network \
    --subnet-mode=custom \
    --bgp-routing-mode=regional

# Create ingress subnet
gcloud compute networks subnets create ingress \
    --network=ingress-network \
    --range=10.0.0.0/24 \
    --region=us-east1

# FW rule to allow SSH and icmp over egress network
gcloud compute firewall-rules create egress-allow-ssh --network egress-network --allow tcp:22
gcloud compute firewall-rules create egress-allow-icmp --network egress-network --allow icmp

# FW rule to allow SSH and icmp over ingress network
gcloud compute firewall-rules create ingress-allow-ssh --network ingress-network --allow tcp:22
gcloud compute firewall-rules create ingress-allow-icmp --network ingress-network --allow icmp

# FW rule to allow socks over ingress network
gcloud compute firewall-rules create ingress-allow-socks5 --network ingress-network --allow tcp:1080
# Instead, I recommend allowing specific CIDR_RANGE 
# gcloud compute firewall-rules create ingress-allow-socks5 --network ingress-network --allow tcp:1080 --source-ranges=CIDR_RANGE
