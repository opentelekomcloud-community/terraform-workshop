variable "cloud" {
  type    = string
  default = "terraform446"
}

variable "redis_password" {
  type      = string
  default   = "Qwerty123!"
  sensitive = true
}
