variable "cloud" {
  type    = string
  default = "workshop"
}

variable "keypair_name" {
  type    = string
  default = "workshop-demo"
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.10.1.0/24"
}

variable "az" {
  type        = string
  description = "OTC AZ, e.g. eu-de-01"
  default     = "eu-de-03"
}

variable "flavor_name" {
  type    = string
  default = "s2.large.2"
}

variable "image_name" {
  type    = string
  default = "Standard_Ubuntu_24.04_amd64_uefi_latest"
}
