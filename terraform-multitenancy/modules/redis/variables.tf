variable "name" {
  description = "Name of the DCS (Redis) instance"
  type        = string
}
variable "engine_version" {
  description = "Version of Redis engine"
  type        = string
  default     = "6.0"
}
variable "capacity" {
  description = "Capacity of the DCS instance in GB"
  type        = number
}
variable "password" {
  description = "Password for Redis instance access"
  type        = string
  sensitive   = true
}
variable "vpc_id" {
  description = "VPC ID where the instance will be deployed"
  type        = string
}
variable "subnet_id" {
  description = "Subnet ID where the instance will be deployed"
  type        = string
}
variable "maintain_begin" {
  description = "Start time of the maintenance window (HH:MM:SS)"
  type        = string
  default     = "02:00:00"
}
variable "maintain_end" {
  description = "End time of the maintenance window (HH:MM:SS)"
  type        = string
  default     = "06:00:00"
}
variable "availability_zone" {
  description = "Availability Zone for the Redis instance"
  type        = string
}
variable "flavor" {
  description = "Flavor of the DCS instance (specifies CPU, memory, etc.)"
  type        = string
  default     = "redis.ha.xu1.tiny.r2.128"
}
