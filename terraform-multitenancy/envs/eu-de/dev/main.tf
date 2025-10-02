provider "opentelekomcloud" {
  cloud = var.cloud
}

data "opentelekomcloud_compute_availability_zones_v2" "zones" {}

module "networking" {
  source            = "../../../modules/networking"
  vpc_name          = "workshop-fgs-vpc"
  vpc_cidr          = "10.10.0.0/16"
  subnet_name       = "workshop-fgs-subnet"
  subnet_cidr       = "10.10.1.0/24"
  subnet_gateway_ip = "10.10.1.1"
  secgroup_name     = "workshop-apigw-sg"
  secgroup_rules = [
    {
      port_range_min = 443
      port_range_max = 443
    },
    {
      port_range_min = 80
      port_range_max = 80
    },
    {
      port_range_min = 8080
      port_range_max = 8080
    }
  ]
}

module "packager" {
  source        = "../../../modules/packager"
  src_dir       = "../../../function"
  build_dir     = "build"
  bucket_name   = "workshop-bucket"
  object_prefix = "function"
}

module "redis" {
  source            = "../../../modules/redis"
  name              = "workshop-redis"
  engine_version    = "6.0"
  capacity          = 0.125
  password          = var.redis_password
  vpc_id            = module.networking.vpc_id
  subnet_id         = module.networking.subnet_id
  maintain_begin    = "02:00:00"
  maintain_end      = "06:00:00"
  availability_zone = data.opentelekomcloud_compute_availability_zones_v2.zones.names[0]
  flavor            = "redis.ha.xu1.tiny.r2.128"
}

module "function" {
  source          = "../../../modules/function"
  name            = "birthday-api"
  description     = "FGS function for birthday API"
  handler         = "handler.func_handler"
  memory_size     = 256
  timeout         = 10
  runtime         = "Python3.9"
  code_type       = "obs"
  code_url        = format("https://%s/%s", module.packager.object_domain, module.packager.object_key)
  agency          = "fg_agency"
  vpc_id          = module.networking.vpc_id
  network_id      = module.networking.subnet_id
  redis_host      = module.redis.private_ip
  redis_port      = "6379"
  redis_password  = var.redis_password
  log_group_name  = "fg-log-group"
  log_stream_name = "fg-log-stream"
}

module "apigw" {
  source = "../../../modules/apigw"

  name               = "workshop-gw"
  description        = "Dedicated gateway for workshop"
  spec_id            = "BASIC"

  availability_zones = [data.opentelekomcloud_compute_availability_zones_v2.zones.names[0]]
  security_group_id  = module.networking.secgroup_id
  vpc_id             = module.networking.vpc_id
  subnet_id          = module.networking.subnet_id

  group_name         = "workshop-group"

  api_name           = "birthday-api"
  request_protocol   = "HTTPS"
  request_method     = "ANY"
  request_uri        = "/hello/{username}"

  function_urn       = module.function.urn
  function_version   = "latest"
  invocation_type    = "sync"
  backend_timeout_ms = 5000

  add_username_path_param = true
}
