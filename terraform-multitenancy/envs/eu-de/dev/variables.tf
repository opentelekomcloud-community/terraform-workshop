variable "cloud" {
  type    = string
  default = "dev"
}

variable "redis_password" {
  type      = string
  default   = "Qwerty123!"
  sensitive = true
}
