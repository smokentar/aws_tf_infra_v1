provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket_prefix = "terraform-state-"

  # Ensure terraform will delete all versions of this bucket
  force_destroy = true
/*
  # Prevent accidental deletion of this bucket when running terraform destroy
  lifecycle {
    prevent_destroy = true
  }
*/
  # Enable versioning
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name  = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Uncomment and re-init
/*
terraform {
  # Partial config; pulls data from backend.hcl
  backend "s3" {
    key = "global/remote_state/terraform.tfstate"
  }

  # Allow any 0.14.x version of Terraform
  required_version = ">= 0.14, < 0.15"

  # Allow any 3.x version of the AWS provider
  required_providers {
    aws = "~> 3.0"
  }
}
*/
