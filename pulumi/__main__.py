"""Pulumi OpenStack (OTC) example: VM on custom subnet + router to external network"""

import pulumi
from pulumi_openstack import images, networking, compute

cfg = pulumi.Config()
instance_count = cfg.get_int("instance_count") or 2

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

# Find latest Debian public image
image = images.get_image(
    name_regex=r"(?i)debian*",
    most_recent=True,
    visibility="public",
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
vms = []
fips = []
for i in range(instance_count):

    # Port on our subnet for the VM
    port = networking.Port(
        f"workshop-port-{i}",
        network_id=net.id,
        fixed_ips=[networking.PortFixedIpArgs(subnet_id=subnet.id)],
        admin_state_up=True,
        security_group_ids=[sg.id],
    )

    # VM attached via the port
    vm = compute.Instance(
        f"workshop-vm-{i}",
        flavor_name="s3.large.2",
        image_id=image.id,
        networks=[compute.InstanceNetworkArgs(port=port.id)],
    )
    vms.append(vm)

    # Allocate and associate a Floating IP to the VM's port
    fip = networking.FloatingIp(
        f"workshop-fip-{i}",
        port_id=port.id,
        pool="admin_external_net"
    )
    fips.append(fip)

pulumi.export("vm_ip", [v.access_ip_v4 for v in vms])
pulumi.export("floating_ips", [f.address for f in fips])
pulumi.export("net_id", net.id)
pulumi.export("subnet_id", subnet.id)
pulumi.export("router_id", router.id)
pulumi.export("external_net_id", ext_net.id)

# Notes:
# - ping floating_ip
# - Configure count: pulumi config set example:instance_count 3
