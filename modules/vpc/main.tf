# VPC, public/private subnets, Internet Gateway, NAT Gateway, route tables, security groups.

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge({ Name = "${var.name_prefix}-vpc" }, var.tags)

  lifecycle {
    prevent_destroy = true
  }
}
