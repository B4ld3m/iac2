locals {
  env    = terraform.workspace
  prefix = "${var.project}-${local.env}"

  bucket_suffix = {
    dev  = "dev001"
    qa   = "qa001"
    prod = "prd001"
  }

  bucket_name = "${local.prefix}-images-${lookup(local.bucket_suffix, local.env, "default")}"

  upload_prefix    = "uploads/"
  processed_prefix = "processed/"

  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
}