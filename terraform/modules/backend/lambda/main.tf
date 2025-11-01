locals {
  post_time_record_source_path      = "${path.module}/../../../../backend/post_time_record/main.py"
  post_time_record_source_exists    = fileexists(local.post_time_record_source_path)
}

data "archive_file" "post_time_record" {
  count       = local.post_time_record_source_exists ? 1 : 0
  type        = "zip"
  source_file = local.post_time_record_source_path
  output_path = "${path.module}/post_time_record.zip"
}

data "archive_file" "post_time_record_placeholder" {
  count                   = local.post_time_record_source_exists ? 0 : 1
  type                    = "zip"
  output_path             = "${path.module}/post_time_record_placeholder.zip"
  source_content          = <<PY
def handler(event, context):
    raise RuntimeError("Placeholder artifact. Deploy real code via backend pipeline.")
PY
  source_content_filename = "main.py"
}

locals {
  post_time_record_package_path = try(data.archive_file.post_time_record[0].output_path, data.archive_file.post_time_record_placeholder[0].output_path)
  post_time_record_package_hash = try(data.archive_file.post_time_record[0].output_base64sha256, data.archive_file.post_time_record_placeholder[0].output_base64sha256)
}

resource "aws_lambda_function" "post_time_record" {
  function_name = "${var.project}-post-time-record"
  role          = var.lambda_role_arn
  handler       = "main.handler"
  runtime       = var.lambda_runtime

  filename         = local.post_time_record_package_path
  source_code_hash = local.post_time_record_package_hash

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}