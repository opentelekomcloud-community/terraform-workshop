output "ssh_command" {
  value = "ssh -i ${var.ansible_kp} ubuntu@${opentelekomcloud_networking_floatingip_v2.fip.address}"
}

output "http_url" {
  value = "http://${opentelekomcloud_networking_floatingip_v2.fip.address}"
}
