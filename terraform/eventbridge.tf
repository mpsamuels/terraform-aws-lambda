resource "aws_cloudwatch_event_rule" "on_s3_upload" {
  count         = var.create_eventbridge == true ? 1 : 0
  name          = "${var.prefix_name}-lambda-rule"
  event_pattern = templatefile("${path.module}/templates/s3_cloudwatch_event.tpl", { bucket = var.upload_bucket_name })
}

resource "aws_cloudwatch_event_target" "lambda_event_target" {
  count     = var.create_eventbridge == true ? 1 : 0
  target_id = "${var.prefix_name}-lambda-target"
  rule      = aws_cloudwatch_event_rule.on_s3_upload[0].name
  arn       = aws_lambda_function.lambda.arn
}