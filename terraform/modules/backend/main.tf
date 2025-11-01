module "dynamodb" {
  source  = "./dynamodb"
  project = var.project
}

module "iam" {
  source    = "./iam"
  project   = var.project
  table_arn = module.dynamodb.table_arn
}

module "lambda" {
  source           = "./lambda"
  project          = var.project
  table_name       = module.dynamodb.table_name
  lambda_role_arn  = module.iam.lambda_role_arn
  lambda_role_name = module.iam.lambda_role_name
  lambda_runtime   = var.lambda_runtime
}

module "api" {
  source                                   = "./api"
  project                                  = var.project
  post_time_record_lambda_invoke_arn       = module.lambda.post_time_record_lambda_invoke_arn
  post_time_record_lambda_function_name    = module.lambda.post_time_record_lambda_function_name
}
