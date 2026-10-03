mock_provider "aws" {}

variables {
  env            = "test"
  vpc_cidr_block = "10.0.0.0/16"

  azs = ["us-east-2a", "us-east-2b"]

  private_app_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
  private_db_subnets  = ["10.0.2.0/24", "10.0.3.0/24"]
  public_subnets      = ["10.0.4.0/24", "10.0.5.0/24"]

  private_app_subnet_tags = {}
  private_db_subnet_tags  = {}
  public_subnet_tags      = {}
  vpc_tags                = {}
}

run "nat_disabled_by_default" {
  command = plan

  assert {
    condition = (
      length(aws_nat_gateway.this) == 0 &&
      length(aws_eip.nat) == 0 &&
      length(aws_route.app_nat) == 0
    )
    error_message = "The default configuration must not create NAT resources."
  }

  assert {
    condition     = length(aws_route_table.db_private) == 2
    error_message = "Database subnets must retain separate route tables."
  }
}

run "single_nat" {
  command = plan

  variables {
    nat_mode = "single"
  }

  assert {
    condition = (
      length(aws_nat_gateway.this) == 1 &&
      length(aws_eip.nat) == 1
    )
    error_message = "Single mode must create exactly one NAT gateway and EIP."
  }

  assert {
    condition     = length(aws_route.app_nat) == 2
    error_message = "Both application route tables must have a NAT route."
  }
}

run "nat_per_az" {
  command = plan

  variables {
    nat_mode = "per_az"
  }

  assert {
    condition = (
      length(aws_nat_gateway.this) == 2 &&
      length(aws_eip.nat) == 2 &&
      length(aws_route.app_nat) == 2
    )
    error_message = "Per-AZ mode must create one NAT gateway, EIP, and application route per AZ."
  }
}

run "reject_invalid_mode" {
  command = plan

  variables {
    nat_mode = "invalid"
  }

  expect_failures = [var.nat_mode]
}