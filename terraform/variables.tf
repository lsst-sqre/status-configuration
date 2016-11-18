variable "aws_access_key" {
  description = "AWS access key id."
}

variable "aws_secret_key" {
  description = "AWS secret access key."
}

variable "aws_default_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

variable "aws_tag" {
  description = "Name tag to apply to AWS resources."
  default     = "monitor"
}

variable "aws_zone_id" {
  description = "Route53 zone id."
  default     = "Z3TH0HRSNU67AM"
}

variable "domain_name" {
  description = "DNS domain."
  default     = "lsst.codes"
}

variable "status_hostname" {
  description = "short name (hostname) of status node."
  default     = "status-test"
}

variable "status_ami" {
  description = "AMI id."
  default     = "ami-d2c924b2"
}
