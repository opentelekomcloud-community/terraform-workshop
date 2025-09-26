locals {
  # Resolve paths relative to the ROOT module
  src_dir_abs   = abspath("${path.root}/${var.src_dir}")
  build_dir_abs = abspath("${path.root}/${var.build_dir}")
  pkg_dir       = "${local.build_dir_abs}/function_pkg"
  zip_path      = "${local.build_dir_abs}/function.zip"
}

# Track changes in your source to trigger rebuilds
locals {
  files       = fileset(local.src_dir_abs, "**")
  source_hash = sha256(join("", [for f in local.files : filesha256("${local.src_dir_abs}/${f}")]))
}

# Build step: install deps and copy sources into build/function_pkg/
resource "null_resource" "build_function" {
  triggers = {
    source_hash = local.source_hash
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      BUILD_DIR="${local.pkg_dir}"
      rm -rf "$${BUILD_DIR}"
      mkdir -p "$${BUILD_DIR}"

      # Install Python dependencies if requirements.txt exists
      if [ -f "${local.src_dir_abs}/requirements.txt" ]; then
        python3 -m pip install -r "${local.src_dir_abs}/requirements.txt" -t "$${BUILD_DIR}"
      fi

      # Copy source code
      cp -R "${local.src_dir_abs}/." "$${BUILD_DIR}/"

      # Ensure build dir exists for the zip
      mkdir -p "${local.build_dir_abs}"
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}

# Zip the staging directory (after deps are installed)
data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = local.pkg_dir
  output_path = local.zip_path

  depends_on = [null_resource.build_function]
}

# OBS bucket for artifacts
resource "opentelekomcloud_obs_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = "private"
}

# Upload the package with a content-addressed key
resource "opentelekomcloud_obs_bucket_object" "object" {
  bucket = opentelekomcloud_obs_bucket.bucket.bucket
  key    = "${var.object_prefix}-${data.archive_file.function_zip.output_md5}.zip"
  source = data.archive_file.function_zip.output_path

  etag       = data.archive_file.function_zip.output_md5
  depends_on = [data.archive_file.function_zip]
}
