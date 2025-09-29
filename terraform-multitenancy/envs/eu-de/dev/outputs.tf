output "function_urn" {
  value = module.function.urn
}

output "api_debug_domain" {
  value = "https://${module.apigw.group_id}.apic.${module.apigw.region}.otc.t-systems.com/hello"
}
