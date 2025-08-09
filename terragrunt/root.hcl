terraform_binary = "terraform"

terraform {
  extra_arguments "common_args" {
    commands  = ["plan", "apply"]
    arguments = ["-lock-timeout=5m"]
  }
}

# OBS-backed remote state (S3-compatible)
# remote_state {
#   generate = {
#     path      = "backend.tf"
#     if_exists = "overwrite_terragrunt"
#   }
#
#   backend = "s3"
#   config = {
#     bucket                  = "otc-tfstate-workshop"
#     key                     = "${path_relative_to_include()}/terraform.tfstate"
#     region                  = "eu-de"
#     # OTC OBS endpoint + path-style is the important bit:
#     endpoints               = { s3 = "https://obs.eu-de.otc.t-systems.com" }
#     force_path_style        = true
#
#     # Using plain S3 backend against non-AWS requires these relaxations:
#     skip_credentials_validation     = true
#     skip_region_validation          = true
#     skip_requesting_account_id      = true
#     skip_metadata_api_check         = true
#     skip_s3_checksum                = true
#
#     access_key = get_env("OBS_ACCESS_KEY", "")
#     secret_key = get_env("OBS_SECRET_KEY", "")
#   }
# }

# Generate provider.tf (Terragrunt will leave backend block empty on disk)
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = ">= 1.36.0"
    }
  }
}
EOF
}
