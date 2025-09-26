variable "name" {
  description = "Name of the FGS function"
  type        = string
}

variable "description" {
  description = "Description of the FGS function"
  type        = string
}

variable "handler" {
  description = "Handler for the function (e.g. handler.lambda_handler)"
  type        = string
}

variable "memory_size" {
  description = "Memory size of the function in MB"
  type        = number
}

variable "timeout" {
  description = "Timeout for the function in seconds"
  type        = number
}

variable "runtime" {
  description = "Runtime environment for the function (e.g. Python3.9)"
  type        = string
}

variable "code_type" {
  description = "Code type for the function (zip, obs, etc.)"
  type        = string
}

variable "code_url" {
  description = "OBS URL or reference to the function package"
  type        = string
}

variable "agency" {
  description = "Agency used by the function to access other services"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for attaching the function"
  type        = string
}

variable "network_id" {
  description = "Subnet/Network ID for attaching the function"
  type        = string
}

variable "redis_host" {
  description = "Redis host IP"
  type        = string
}

variable "redis_port" {
  description = "Redis port"
  type        = string
}

variable "redis_password" {
  description = "Redis password"
  type        = string
  sensitive   = true
}

variable "log_group_name" {
  description = "Log group name for FunctionGraph logs"
  type        = string
}

variable "log_stream_name" {
  description = "Log stream name for FunctionGraph logs"
  type        = string
}
