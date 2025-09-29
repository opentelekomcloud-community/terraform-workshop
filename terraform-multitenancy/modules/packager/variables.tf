variable "src_dir" {
  description = "Path to the function source directory, relative to the ROOT module."
  type        = string
}

variable "build_dir" {
  description = "Build directory relative to the ROOT module (will be created if missing)."
  type        = string
  default     = "build"
}

variable "bucket_name" {
  description = "OBS bucket name to upload the packaged ZIP to."
  type        = string
}

variable "object_prefix" {
  description = "Prefix for the OBS object key (final key will be <prefix>-<md5>.zip)."
  type        = string
  default     = "function"
}
