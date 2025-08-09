# Keypair
data "opentelekomcloud_compute_keypair_v2" "kp" {
  name = var.keypair_name
}

# VPC + subnet
resource "opentelekomcloud_vpc_v1" "vpc" {
  name = "workshop-vpc"
  cidr = var.vpc_cidr
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet" {
  name              = "workshop-subnet"
  cidr              = var.subnet_cidr
  gateway_ip        = cidrhost(var.subnet_cidr, 1)
  vpc_id            = opentelekomcloud_vpc_v1.vpc.id
  dns_list          = ["100.125.4.25", "100.125.129.199"]
  availability_zone = var.az
}

# Security group (SSH only)
resource "opentelekomcloud_networking_secgroup_v2" "sg" {
  name        = "workshop-sg"
  description = "Allow SSH from anywhere (demo)"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "ssh_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.sg.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "nginx" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.sg.id
}

# Get image/flavor by name
data "opentelekomcloud_images_image_v2" "img" {
  name        = var.image_name
  most_recent = true
}

data "opentelekomcloud_compute_flavor_v2" "flavor" {
  name = var.flavor_name
}

# Port in subnet with SG
resource "opentelekomcloud_networking_port_v2" "port" {
  name           = "workshop-port"
  network_id     = opentelekomcloud_vpc_subnet_v1.subnet.network_id
  admin_state_up = true

  security_group_ids = [
    opentelekomcloud_networking_secgroup_v2.sg.id
  ]
}

resource "opentelekomcloud_blockstorage_volume_v2" "vol_1" {
  name              = "vol_1"
  size              = 50
  volume_type       = "SSD"
  image_id          = data.opentelekomcloud_images_image_v2.img.id
  availability_zone = var.az
}

# VM
resource "opentelekomcloud_compute_instance_v2" "vm" {
  name              = "workshop-vm"
  flavor_id         = data.opentelekomcloud_compute_flavor_v2.flavor.id
  key_pair          = data.opentelekomcloud_compute_keypair_v2.kp.name
  availability_zone = var.az

  network {
    port = opentelekomcloud_networking_port_v2.port.id
  }

  block_device {
    uuid                  = opentelekomcloud_blockstorage_volume_v2.vol_1.id
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

}

# Floating IP and association
resource "opentelekomcloud_networking_floatingip_v2" "fip" {
  pool = "admin_external_net"
}

resource "opentelekomcloud_networking_floatingip_associate_v2" "fip_assoc" {
  floating_ip = opentelekomcloud_networking_floatingip_v2.fip.address
  port_id     = opentelekomcloud_networking_port_v2.port.id
}

# Provision with Ansible (installs nginx)
resource "null_resource" "ansible_provision" {
  # Re-run if the floating IP changes
  triggers = {
    ip = opentelekomcloud_networking_floatingip_v2.fip.address
  }

  depends_on = [
    opentelekomcloud_networking_floatingip_associate_v2.fip_assoc
  ]

  provisioner "local-exec" {
    command = <<EOT
      set -e
      ansible-playbook -i ${opentelekomcloud_networking_floatingip_v2.fip.address}, --private-key ${var.ansible_kp} -e target=all ansible/site.yaml -u ubuntu --ssh-extra-args='-o StrictHostKeyChecking=no'
    EOT
    interpreter = ["/bin/bash", "-c"]
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }
}

output "ssh_command" {
  value = "ssh -i ${var.ansible_kp} ubuntu@${opentelekomcloud_networking_floatingip_v2.fip.address}"
}

output "http_url" {
  value = "http://${opentelekomcloud_networking_floatingip_v2.fip.address}"
}