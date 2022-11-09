terraform {
  required_version = "~> 1.3.0"
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "~> 1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0, < 5.0.0"
    }
  }
}
