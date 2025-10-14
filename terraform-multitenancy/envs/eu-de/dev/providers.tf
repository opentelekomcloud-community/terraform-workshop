terraform {
  required_version = ">= 1.6.0"
  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = ">= 1.36.0"
    }
  }
  backend "s3" {
    endpoints = {
      s3 = "https://obs.eu-de.otc.t-systems.com/"
    }
    key                         = "terraform_state/dev"
    bucket                      = "otc-tfstate-workshop"
    region                      = "eu-de"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }
}
