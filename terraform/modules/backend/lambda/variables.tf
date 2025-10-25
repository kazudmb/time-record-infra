variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "lambda_role_arn" {
  description = "IAM role ARN for Lambda"
  type        = string
}

variable "lambda_role_name" {
  description = "IAM role name for Lambda"
  type        = string
}

variable "lambda_runtime" {
  description = "Python runtime for Lambda functions"
  type        = string
  default     = "python3.11"
}
