variable "name" {
  default = "terraform-vpc"
}

variable "cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  default = "10.0.0.0/24,10.0.1.0/24"
}

variable "private_subnets" {
  default = "10.0.10.0/24,10.0.11.0/24"
}

variable "azs" {
  default = "us-west-2a,us-west-2b"
}

variable "enable_dns_hostnames" {
  default = true
}

variable "enable_dns_support" {
  default = true
}

variable "region" {
  default = "us-west-2"
}

variable "nat_gateways_count" {
  default = 1
}

variable "s3_endpoint_enabled" {
  default = true
}

variable "dynamodb_endpoint_enabled" {
  default = true
}

variable "environment" {
  description = "AWS Environment tag, example 'dev', 'stage' or 'prod'. Defaults to 'unknown'"
  default     = "unknown"
}

variable "team" {
  description = "AWS tag 'Team' used to associate with a team. E.g. 'adc-sre' or ''"
  default     = "unknown"
}

variable "role" {
  description = "AWS tag 'Role' used to associate with a role the service takes part in, example 'governor' or 'batch'. A role should be more general and covers multiple services"
  default     = "unknown"
}

variable "service" {
  description = "AWS tag 'Service' used to associate with a role the service takes part in, example 'importer' or 'exporter' or 'pdp-api', basically a subset of the role tag"
  default     = "unknown"
}

variable "description" {
  description = "Friendly description of the component and its use"
  default     = "unknown"
}

variable "product" {
  description = "name of the product which the service belongs"
  default     = "unknown"
}

variable "owner" {
  description = "team/contact email address"
  default     = "unknown"
}

