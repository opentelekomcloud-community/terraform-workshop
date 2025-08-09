provider "opentelekomcloud" {
  cloud = "terraform446"
}

# Minimal VPC + Subnet
resource "opentelekomcloud_vpc_v1" "workshop_vpc" {
  name = "tg-workshop-vpc"
  cidr = "10.20.0.0/16"
}

resource "opentelekomcloud_vpc_subnet_v1" "workshop_subnet" {
  name       = "tg-workshop-subnet"
  cidr       = "10.20.1.0/24"
  gateway_ip = "10.20.1.1"
  vpc_id     = opentelekomcloud_vpc_v1.workshop_vpc.id
  dns_list   = ["100.125.4.25", "100.125.129.199"]
}

# A tiny ECS instance (adjust image/flavor to what exists in your project)
resource "opentelekomcloud_compute_instance_v2" "vm" {
  name            = "tg-workshop-ecs"
  image_name      = "Standard_Ubuntu_22.04_latest"
  flavor_name     = "s2.medium.1"
  security_groups = ["default"]

  network {
    uuid = opentelekomcloud_vpc_subnet_v1.workshop_subnet.id
  }

  # Optional: inject user data
  user_data = <<-EOT
    #!/bin/bash
    echo "hi from terragrunt" > /etc/motd
  EOT
}

output "vm_id"   { value = opentelekomcloud_compute_instance_v2.vm.id }
output "subnet_id" { value = opentelekomcloud_vpc_subnet_v1.workshop_subnet.id }
