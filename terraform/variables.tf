variable "region" {
  description = "The aws region. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html"
  type        = string
  default     = "eu-west-1"
}

variable "availability_zones_count" {
  description = "The number of AZs."
  type        = number
  default     = 2
}

variable "project" {
  description = "Name to be used on all the resources as identifier. e.g. Project name, Application name"
  # description = "Name of the project deployment."
  type = string
  default = "eks-dev"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "10.0.0.0/16"
}

variable "secondary_cidr_blocks" {
  description = "Add secondery CIDR block for the VPC."
  type        = string
  default     = "172.0.0.0/16"
}

variable "subnet_cidr_bits" {
  description = "The number of subnet bits for the CIDR. For example, specifying a value 8 for this parameter will create a CIDR with a mask of /24."
  type        = number
  default     = 8
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    "Project"     = "TerraformEKS"
    "Environment" = "Development"
    "Owner"       = "Aharon Nadav"
    "Name"        = "EKS-Nodes"
  }
}

variable "ecr_name" {
  description = "The name of the ECR repository"
  type = list(string)
  default = ["ecr-tf"]
}

variable "image_mutability" {
  description = "Provide image mutability"
  type = string
  default = "IMMUTABLE"
}

variable "encryption_type" {
    description = "Provide type of encryption"
    type = string
    default = "KMS"
}

variable "spot_instance_types"{
    default = ["t3.small","t2.small"]
    description = "List of instance types for SPOT instance selection"
}
variable "ondemand_instance_type"{
    default = "t3.medium"
    description = "On Demand instance type"
}
variable "spot_max_size"{
    default = 2
    description = "How many SPOT instance can be created max"
}
variable "spot_desired_size"{
    default = 2
    description = "How many SPOT instance should be running at all times"
}
variable "ondemand_desired_size"{
    default = 2
    description = "How many OnDemand instances should be running at all times"
}