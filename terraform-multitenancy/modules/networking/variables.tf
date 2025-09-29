variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "subnet_gateway_ip" {
  description = "Gateway IP address for the subnet"
  type        = string
}

variable "secgroup_name" {
  description = "Name of the security group"
  type        = string
}

variable "secgroup_rules" {
  description = "Map of security group rules"
  type = list(object({
    direction        = optional(string, "ingress")
    ethertype        = optional(string, "IPv4")
    protocol         = optional(string, "tcp")
    port_range_min   = number
    port_range_max   = number
    remote_ip_prefix = optional(string, "0.0.0.0/0")
  }))
  default = []
}