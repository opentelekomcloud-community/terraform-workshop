"""Pulumi OpenStack (OTC) example: VM on custom subnet + router to external network"""

import pulumi
from pulumi_openstack import images, networking, compute

# External network lookup (router:external = true)
ext_net = networking.get_network(external=True)

# Router with external gateway + interface to our subnet
router = networking.Router(
    "workshop-router",
    admin_state_up=True,
    external_gateway=ext_net.id,
)

# Network + Subnet
net = networking.Network(
    "workshop-net",
    admin_state_up=True
)

subnet = networking.Subnet(
    "workshop-subnet",
    network_id=net.id,
    cidr="10.0.0.0/24",
    ip_version=4,
    dns_nameservers=["8.8.8.8", "1.1.1.1"],
)

ri = networking.RouterInterface(
    "workshop-ri",
    router_id=router.id,
    subnet_id=subnet.id
)

# Security group allowing ICMP (ping)
sg = networking.SecGroup(
    "workshop-sg",
    description="Allow ICMP for ping",
)

icmp_ingress = networking.SecGroupRule(
    "workshop-sg-icmp-ingress",
    direction="ingress",
    ethertype="IPv4",
    protocol="icmp",
    remote_ip_prefix="0.0.0.0/0",
    security_group_id=sg.id,
)

# Port on our subnet for the VM
port = networking.Port(
    "workshop-port",
    network_id=net.id,
    fixed_ips=[networking.PortFixedIpArgs(subnet_id=subnet.id)],
    admin_state_up=True,
    security_group_ids=[sg.id],
)

# Find latest Debian public image
image = images.get_image(
    name_regex=r"(?i)debian*",
    most_recent=True,
    visibility="public",
)

# VM attached via the port
vm = compute.Instance(
    "workshop-vm",
    flavor_name="s3.large.2",
    image_id=image.id,
    networks=[compute.InstanceNetworkArgs(port=port.id)],
)

# Allocate and associate a Floating IP to the VM's port
fip = networking.FloatingIp(
    "workshop-fip",
    port_id=port.id,
    pool="admin_external_net"
)

pulumi.export("vm_ip", vm.access_ip_v4)
pulumi.export("net_id", net.id)
pulumi.export("subnet_id", subnet.id)
pulumi.export("router_id", router.id)
pulumi.export("external_net_id", ext_net.id)
pulumi.export("floating_ip", fip.address)

# Notes:
# - ping floating_ip
