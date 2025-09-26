resource "opentelekomcloud_dcs_instance_v2" "redis" {
  name               = var.name
  engine             = "Redis"
  engine_version     = var.engine_version
  capacity           = var.capacity
  password           = var.password
  vpc_id             = var.vpc_id
  subnet_id          = var.subnet_id
  maintain_begin     = var.maintain_begin
  maintain_end       = var.maintain_end
  availability_zones = [var.availability_zone]
  flavor             = var.flavor
}
