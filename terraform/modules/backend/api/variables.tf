variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "post_time_record_lambda_invoke_arn" {
  description = "Invoke ARN for POST /time-record Lambda function"
  type        = string
}

variable "post_time_record_lambda_function_name" {
  description = "Function name for POST /time-record Lambda function"
  type        = string
}