locals {
  sg_rules = [for r in var.secgroup_rules : merge({}, r)]
}

resource "opentelekomcloud_vpc_v1" "vpc" {
  name  = var.vpc_name
  cidr  = var.vpc_cidr
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet" {
  name       = var.subnet_name
  cidr       = var.subnet_cidr
  gateway_ip = var.subnet_gateway_ip
  vpc_id     = opentelekomcloud_vpc_v1.vpc.id
}

resource "opentelekomcloud_networking_secgroup_v2" "apigw" {
  name        = var.secgroup_name
  description = "Allow necessary ports from everywhere"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "rules" {
  for_each          = { for idx, r in local.sg_rules : idx => r }

  direction         = each.value.direction
  ethertype         = each.value.ethertype
  protocol          = each.value.protocol
  port_range_min    = each.value.port_range_min
  port_range_max    = each.value.port_range_max
  remote_ip_prefix  = each.value.remote_ip_prefix
  security_group_id = opentelekomcloud_networking_secgroup_v2.apigw.id
}
