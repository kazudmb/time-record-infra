output "post_time_record_lambda_function_name" {
  value       = aws_lambda_function.post_time_record.function_name
  description = "Lambda function name for POST /time-record"
}

output "post_time_record_lambda_invoke_arn" {
  value       = aws_lambda_function.post_time_record.invoke_arn
  description = "Invoke ARN for POST /time-record Lambda function"
}