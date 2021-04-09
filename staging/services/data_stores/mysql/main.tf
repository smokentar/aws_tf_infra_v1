### STAGING

provider "aws" {
  region = "us-east-1"
}

module "mysql" {
  source = "github.com/smokentar/aws_tf_modules//services/data_stores/mysql?ref=staging"

  db_instance_environment = "staging"
}

terraform {
  # Partial config; pulls data from backend.hcl
  backend "s3" {
    key = "staging/services/data_stores/mysql/terraform.tfstate"
  }
}

# Ensure that outputs from the module are exported to the tfstate file
# Post v12 outputs from child modules must be exported in the root module
output "mysql_export" {
  value = module.mysql
}