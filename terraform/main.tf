terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# When running locally, tflocal (or the localstack-specific provider config)
# overrides endpoint_url. The profile/region here are sensible defaults so
# the same config works in CI with real AWS credentials if ever needed.
provider "aws" {
  region = var.aws_region

  # LocalStack does not validate real credentials; skip_* flags prevent
  # Terraform from making validation calls that would fail locally.
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # LocalStack endpoint — only active when LOCALSTACK_ENDPOINT is set.
  # tflocal sets this automatically; in real AWS, leave the env var unset.
  dynamic "endpoints" {
    for_each = var.localstack_endpoint != "" ? [1] : []
    content {
      ec2 = var.localstack_endpoint
      s3  = var.localstack_endpoint
      iam = var.localstack_endpoint
    }
  }

  default_tags {
    tags = local.common_tags
  }
}

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

# ─── Network (reusable module) ────────────────────────────────────────────────
module "network" {
  source = "./modules/network"

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  availability_zones  = var.availability_zones
  ssh_allowed_cidr    = var.ssh_allowed_cidr
  tags                = local.common_tags
}

# ─── EC2 — Web Tier ───────────────────────────────────────────────────────────
resource "aws_instance" "web" {
  count         = var.web_instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = module.network.public_subnet_ids[count.index % length(module.network.public_subnet_ids)]

  vpc_security_group_ids = [module.network.web_security_group_id]

  # DEVIATION: no key_pair specified — in production this must be set.
  # Omitted here because LocalStack does not enforce it and the spec did
  # not include a key name variable, but SSH without a key pair is useless.

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-web-${count.index + 1}"
    Tier = "web"
  })
}

# ─── S3 — Application Logs ────────────────────────────────────────────────────
resource "aws_s3_bucket" "app_logs" {
  bucket = var.log_bucket_name

  tags = merge(local.common_tags, {
    Name    = var.log_bucket_name
    Purpose = "application-logs"
  })
}

resource "aws_s3_bucket_versioning" "app_logs" {
  bucket = aws_s3_bucket.app_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "app_logs" {
  bucket = aws_s3_bucket.app_logs.id

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiry_days
    }
  }
}

# DEVIATION: Block public access explicitly. The spec did not mention this,
# but an unprotected log bucket would be a P0 security finding. Every S3
# bucket should have public access blocked unless it is a static-site origin.
resource "aws_s3_bucket_public_access_block" "app_logs" {
  bucket = aws_s3_bucket.app_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ─── Orphan EBS Volume (intentional, for Part B) ─────────────────────────────
# This volume is deliberately left unattached so the Cost Janitor can
# detect it as an "available" EBS volume.
resource "aws_ebs_volume" "orphan" {
  availability_zone = var.availability_zones[0]
  size              = var.orphan_ebs_size_gb
  type              = "gp3"

  tags = merge(local.common_tags, {
    Name    = "${var.project}-${var.environment}-orphan-test"
    Purpose = "janitor-test-orphan"
    # Intentionally omitting "Owner" here to also trigger the missing-tag check
  })
}
