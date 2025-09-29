resource "opentelekomcloud_fgs_function_v2" "this" {
  name        = var.name
  app         = "default"
  description = var.description
  handler     = var.handler
  memory_size = var.memory_size
  timeout     = var.timeout
  runtime     = var.runtime
  code_type   = var.code_type
  code_url    = var.code_url
  agency      = var.agency

  # Networking
  vpc_id     = var.vpc_id
  network_id = var.network_id

  # Env vars for Redis
  user_data = jsonencode({
    REDIS_HOST     = var.redis_host
    REDIS_PORT     = var.redis_port
    REDIS_PASSWORD = var.redis_password
  })

  # Logging
  log_group_id   = opentelekomcloud_lts_group_v2.group.id
  log_topic_id   = opentelekomcloud_lts_stream_v2.stream.id
  log_group_name = opentelekomcloud_lts_group_v2.group.group_name
  log_topic_name = opentelekomcloud_lts_stream_v2.stream.stream_name
}

resource "opentelekomcloud_lts_group_v2" "group" {
  group_name  = var.log_group_name
  ttl_in_days = 30
}

resource "opentelekomcloud_lts_stream_v2" "stream" {
  group_id    = opentelekomcloud_lts_group_v2.group.id
  stream_name = var.log_stream_name
}
