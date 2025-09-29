variable "name" {
  description = "Name of the API Gateway instance"
  type        = string
}

variable "description" {
  description = "Description of the API Gateway"
  type        = string
  default     = "Dedicated gateway for workshop"
}

variable "spec_id" {
  description = "Gateway spec ID (e.g., BASIC)"
  type        = string
  default     = "BASIC"
}

variable "availability_zones" {
  description = "List with one AZ name for the gateway (e.g., [data...zones.names[0]])"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID attached to the gateway"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the gateway will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the gateway will be deployed"
  type        = string
}

variable "bandwidth_size" {
  description = "Egress/public bandwidth size (MBits/s)"
  type        = number
  default     = 5
}

variable "ingress_bandwidth_size" {
  description = "Ingress bandwidth size (MBits/s) for a dedicated gateway"
  type        = number
  default     = 5
}

variable "ingress_bandwidth_charging_mode" {
  description = "Charging mode for ingress bandwidth (e.g., bandwidth)"
  type        = string
  default     = "bandwidth"
}

variable "group_name" {
  description = "API group name"
  type        = string
  default     = "workshop-group"
}

variable "api_name" {
  description = "API name"
  type        = string
  default     = "birthday-api"
}

variable "request_protocol" {
  description = "Protocol for the request (HTTP/HTTPS)"
  type        = string
  default     = "HTTPS"
}

variable "request_method" {
  description = "HTTP method to route (GET, POST, ANY, etc.)"
  type        = string
  default     = "ANY"
}

variable "request_uri" {
  description = "Request URI/path for the API (supports path params)"
  type        = string
  default     = "/hello/{username}"
}

variable "function_urn" {
  description = "FunctionGraph function URN used as API backend"
  type        = string
}

variable "function_version" {
  description = "FunctionGraph version to invoke (e.g., latest)"
  type        = string
  default     = "latest"
}

variable "invocation_type" {
  description = "Invocation type for FunctionGraph backend (sync/async)"
  type        = string
  default     = "sync"
}

variable "backend_timeout_ms" {
  description = "Backend timeout in milliseconds"
  type        = number
  default     = 5000
}

variable "add_username_path_param" {
  description = "If true, creates a PATH param named 'username'"
  type        = bool
  default     = true
}
