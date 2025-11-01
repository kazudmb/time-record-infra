output "dynamodb_table_name" {
  value       = module.dynamodb.table_name
  description = "Name of the DynamoDB table"
}

output "dynamodb_table_arn" {
  value       = module.dynamodb.table_arn
  description = "ARN of the DynamoDB table"
}

output "lambda_role_arn" {
  value       = module.iam.lambda_role_arn
  description = "IAM role ARN used by the Lambda functions"
}

output "lambda_role_name" {
  value       = module.iam.lambda_role_name
  description = "IAM role name used by the Lambda functions"
}

output "api_endpoint" {
  value       = module.api.api_endpoint
  description = "Base URL of the HTTP API"
}

output "post_time_record_lambda_function_name" {
  value       = module.lambda.post_time_record_lambda_function_name
  description = "Lambda function name for POST /time-record"
}

output "post_time_record_lambda_invoke_arn" {
  value       = module.lambda.post_time_record_lambda_invoke_arn
  description = "Invoke ARN for POST /time-record Lambda function"
}
