resource "random_string" "lambda_src_hash" {
  length  = 8
  special = false
  keepers = {
    variables = "${sha256("${var.lambda}")}"
  }
}

data "archive_file" "source" {
  type        = "zip"
  output_path = "${path.root}/lambda_packages/${var.prefix_name}-${random_string.lambda_src_hash.result}.zip"
  source {
    content  = var.lambda
    filename = var.file_name
  }
}

resource "aws_lambda_function" "lambda" {
  filename      = "${path.root}/lambda_packages/${var.prefix_name}-${random_string.lambda_src_hash.result}.zip"
  function_name = "${var.prefix_name}-lambda"
  role          = aws_iam_role.content_type_check_lambda_role.arn
  handler       = var.handler
  runtime       = var.runtime
  depends_on = [
    data.archive_file.source
  ]
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  count         = var.create_eventbridge == true ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.on_s3_upload[0].arn
}