output "vpc_id" {
  description = "ID of the created VPC"
  value       = opentelekomcloud_vpc_v1.vpc.id
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = opentelekomcloud_vpc_subnet_v1.subnet.id
}

output "secgroup_id" {
  description = "ID of the created security group"
  value       = opentelekomcloud_networking_secgroup_v2.apigw.id
}
