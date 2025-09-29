resource "opentelekomcloud_apigw_gateway_v2" "gw" {
  name        = var.name
  description = var.description
  spec_id     = var.spec_id

  bandwidth_size                  = var.bandwidth_size
  ingress_bandwidth_size          = var.ingress_bandwidth_size
  ingress_bandwidth_charging_mode = var.ingress_bandwidth_charging_mode

  availability_zones = var.availability_zones
  security_group_id  = var.security_group_id
  vpc_id             = var.vpc_id
  subnet_id          = var.subnet_id
}

resource "opentelekomcloud_apigw_group_v2" "group" {
  name        = var.group_name
  instance_id = opentelekomcloud_apigw_gateway_v2.gw.id
}

resource "opentelekomcloud_apigw_api_v2" "api" {
  name             = var.api_name
  group_id         = opentelekomcloud_apigw_group_v2.group.id
  gateway_id       = opentelekomcloud_apigw_gateway_v2.gw.id
  type             = "Public"
  request_protocol = var.request_protocol
  request_method   = var.request_method
  request_uri      = var.request_uri

  # FunctionGraph backend
  func_graph {
    function_urn    = var.function_urn
    invocation_type = var.invocation_type
    timeout         = var.backend_timeout_ms
    version         = var.function_version
  }

  dynamic "request_params" {
    for_each = var.add_username_path_param ? [1] : []
    content {
      name     = "username"
      location = "PATH"
      type     = "STRING"
      required = true
    }
  }
}

resource "opentelekomcloud_apigw_api_publishment_v2" "pub" {
  gateway_id     = opentelekomcloud_apigw_gateway_v2.gw.id
  environment_id = "DEFAULT_ENVIRONMENT_RELEASE_ID"
  api_id         = opentelekomcloud_apigw_api_v2.api.id
}
