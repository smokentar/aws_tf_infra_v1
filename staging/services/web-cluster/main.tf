#STAGING

provider "aws" {
  region = "us-east-1"
}

module "web_cluster" {
  source = "github.com/smokentar/aws_tf_modules//services/web_cluster?ref=staging"

  # Pass in staging-specific variables
  cluster_name = "web-staging"
  db_remote_state_bucket = "terraform-state-20210409171444659800000001"
  db_remote_state_key = "staging/services/data_stores/mysql/terraform.tfstate"
  min_size_asg = 2
  max_size_asg = 2
  instance_type  = "t2.micro"
}

# Test any inbound traffic to the ALB fronting the initial web servers here
# To apply to prod - implement in the web_cluster module
resource "aws_security_group_rule" "allow_test_inbound" {
  type = "ingress"
  security_group_id = module.web_cluster.alb_sg_id

  from_port = 12345
  to_port = 12345
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

terraform {
  # Partial config; pulls data from backend.hcl
  backend "s3" {
    key = "staging/services/web-cluster/terraform.tfstate"
  }
}

# Ensure that outputs from the module are exported to the remote tfstate file
# Post v12 outputs from child modules must be exported in the root module
output "web_cluster_export" {
  value = module.web_cluster
}