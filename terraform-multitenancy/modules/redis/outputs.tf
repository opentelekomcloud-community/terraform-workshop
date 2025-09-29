output "id" {
  description = "ID of the DCS (Redis) instance"
  value       = opentelekomcloud_dcs_instance_v2.redis.id
}

output "name" {
  description = "Name of the DCS instance"
  value       = opentelekomcloud_dcs_instance_v2.redis.name
}

output "private_ip" {
  description = "Private IP address"
  value       = opentelekomcloud_dcs_instance_v2.redis.private_ip
}
