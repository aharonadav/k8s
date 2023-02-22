variable "ecr_name" {
  description = "The name of the ECR repository"
  type = any
  default = null
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

variable "tags" {
  description = "The key-value for tagging"
  type = map(string)
  default = {}
}