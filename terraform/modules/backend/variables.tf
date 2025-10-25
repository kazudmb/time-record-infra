variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "lambda_runtime" {
  description = "Python runtime for Lambda functions"
  type        = string
  default     = "python3.11"
}
