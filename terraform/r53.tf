resource "aws_route53_record" "r53_apigw" {
  count   = var.create_api_gw == true ? 1 : 0
  name    = aws_api_gateway_domain_name.api_gw_domain_name[0].domain_name
  type    = "A"
  zone_id = var.r53_zone

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.api_gw_domain_name[0].regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api_gw_domain_name[0].regional_zone_id
  }
}