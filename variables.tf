variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 instance type (kept free-tier eligible by default)"
  type        = string
  default     = "t3.micro"
}

variable "my_ip" {
  description = "Your public IP in CIDR notation, e.g. 203.0.113.5/32. Used to restrict SSH access. Get yours from https://checkip.amazonaws.com"
  type        = string
}

variable "project_name" {
  description = "Used as a prefix/tag on all resources, so they're easy to identify and tear down together"
  type        = string
  default     = "task-tracker"
}

variable "key_pair_name" {
  description = "Name of an EXISTING EC2 key pair (created manually in the AWS console) used for SSH access. The private key is never handled by Terraform — only this name is referenced."
  type        = string
}

variable "bucket_suffix" {
  description = "Random or unique suffix to make the S3 bucket name globally unique (S3 bucket names must be unique across ALL AWS accounts, not just yours)"
  type        = string
}
