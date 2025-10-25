module "dynamodb" {
  source  = "./dynamodb"
  project = var.project
}

module "iam" {
  source    = "./iam"
  project   = var.project
  table_arn = module.dynamodb.table_arn
}

module "api" {
  source                      = "./api"
  project                     = var.project
  get_lambda_invoke_arn       = module.lambda.get_lambda_invoke_arn
  get_lambda_function_name    = module.lambda.get_lambda_function_name
  upsert_lambda_invoke_arn    = module.lambda.upsert_lambda_invoke_arn
  upsert_lambda_function_name = module.lambda.upsert_lambda_function_name
}
