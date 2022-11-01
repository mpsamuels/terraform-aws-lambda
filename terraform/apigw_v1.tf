resource "aws_api_gateway_rest_api" "apiLambda" {
  count = var.create_api_gw == true ? 1 : 0
  name  = "${var.prefix_name}-lambda-gw-v1"
}

resource "aws_api_gateway_resource" "proxy" {
  count       = var.create_api_gw == true ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.apiLambda[0].id
  parent_id   = aws_api_gateway_rest_api.apiLambda[0].root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxyMethod" {
  count         = var.create_api_gw == true ? 1 : 0
  rest_api_id   = aws_api_gateway_rest_api.apiLambda[0].id
  resource_id   = aws_api_gateway_resource.proxy[0].id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  count       = var.create_api_gw == true ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.apiLambda[0].id
  resource_id = aws_api_gateway_method.proxyMethod[0].resource_id
  http_method = aws_api_gateway_method.proxyMethod[0].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "response_200" {
  count       = var.create_api_gw == true ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.apiLambda[0].id
  resource_id = aws_api_gateway_resource.proxy[0].id
  http_method = aws_api_gateway_method.proxyMethod[0].http_method
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  count       = var.create_api_gw == true ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.apiLambda[0].id
  resource_id = aws_api_gateway_resource.proxy[0].id
  http_method = aws_api_gateway_method.proxyMethod[0].http_method
  status_code = aws_api_gateway_method_response.response_200[0].status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'https://www.${var.domain_name}'"
  }
  depends_on = [
    aws_api_gateway_integration.lambda
  ]
}

resource "aws_api_gateway_method" "proxy_root" {
  count         = var.create_api_gw == true ? 1 : 0
  rest_api_id   = aws_api_gateway_rest_api.apiLambda[0].id
  resource_id   = aws_api_gateway_rest_api.apiLambda[0].root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  count       = var.create_api_gw == true ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.apiLambda[0].id
  resource_id = aws_api_gateway_method.proxy_root[0].resource_id
  http_method = aws_api_gateway_method.proxy_root[0].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}


resource "aws_api_gateway_deployment" "apideploy" {
  count = var.create_api_gw == true ? 1 : 0
  depends_on = [
    aws_api_gateway_integration.lambda_root[0],
  ]
  rest_api_id = aws_api_gateway_rest_api.apiLambda[0].id
}

resource "aws_lambda_permission" "apigw" {
  count         = var.create_api_gw == true ? 1 : 0
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.apiLambda[0].execution_arn}/*/*"
}

resource "aws_api_gateway_domain_name" "api_gw_domain_name" {
  count                    = var.create_api_gw == true ? 1 : 0
  domain_name              = "${var.stage_name}.${var.domain_name}"
  regional_certificate_arn = var.aws_acm_certificate
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "api_gw_mapping" {
  count       = var.create_api_gw == true ? 1 : 0
  api_id      = aws_api_gateway_rest_api.apiLambda[0].id
  domain_name = aws_api_gateway_domain_name.api_gw_domain_name[0].domain_name
}

resource "aws_api_gateway_stage" "stage" {
  count         = var.create_api_gw == true ? 1 : 0
  deployment_id = aws_api_gateway_deployment.apideploy[0].id
  rest_api_id   = aws_api_gateway_rest_api.apiLambda[0].id
  stage_name    = var.stage_name
}

resource "aws_api_gateway_method_settings" "method_settings" {
  count       = var.create_api_gw == true ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.apiLambda[0].id
  stage_name  = aws_api_gateway_stage.stage[0].stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}