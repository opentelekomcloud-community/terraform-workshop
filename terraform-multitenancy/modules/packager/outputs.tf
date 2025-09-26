output "zip_md5" {
  description = "MD5 hash of the built ZIP contents."
  value       = data.archive_file.function_zip.output_md5
}

output "zip_path" {
  description = "Local filesystem path of the built ZIP."
  value       = data.archive_file.function_zip.output_path
}

output "object_key" {
  description = "Uploaded OBS object key for the package."
  value       = opentelekomcloud_obs_bucket_object.object.key
}

output "object_url" {
  description = "Convenience value to reference in other modules (bucket/key)."
  value       = "${opentelekomcloud_obs_bucket.bucket.bucket}/${opentelekomcloud_obs_bucket_object.object.key}"
}

output "object_domain" {
  description = "Uploaded OBS bucket domain name."
  value       = opentelekomcloud_obs_bucket.bucket.bucket_domain_name
}