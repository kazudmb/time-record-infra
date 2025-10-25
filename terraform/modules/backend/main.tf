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
}
