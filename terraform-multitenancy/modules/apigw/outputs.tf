output "gateway_id" {
  description = "ID of the dedicated API Gateway instance"
  value       = opentelekomcloud_apigw_gateway_v2.gw.id
}

output "group_id" {
  description = "API group ID"
  value       = opentelekomcloud_apigw_group_v2.group.id
}

output "api_id" {
  description = "API ID"
  value       = opentelekomcloud_apigw_api_v2.api.id
}

output "region" {
  description = "API ID"
  value       = opentelekomcloud_apigw_api_v2.api.region
}