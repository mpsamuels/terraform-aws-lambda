
resource "aws_iam_role" "content_type_check_lambda_role" {
  name               = "${var.prefix_name}-lambda-role"
  assume_role_policy = file("${path.module}/templates/lambda_sts_policy.tpl")
}

resource "aws_iam_role_policy_attachment" "content_type_check_lambda_basic_policy_attachment" {
  role       = aws_iam_role.content_type_check_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "content_type_check_lambda_s3_read_policy" {
  name   = "${var.prefix_name}-policy"
  role   = aws_iam_role.content_type_check_lambda_role.id
  policy = var.policy
}