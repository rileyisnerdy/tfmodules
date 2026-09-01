variable "vpc_id" {
  description = "The ID of the VPC where the security groups will be created"
  type        = string
  default     = ""
}


variable "aws_resource_nametag_prefix" {
  description = "The prefix used for naming AWS resources (e.g. dev_rdais)"
  type        = string
  default     = ""
}


variable "globals" {
  description = "Map of environment specific cidr values"
  type = map(string)
  default = {
    placeholder = "default"
  }
}