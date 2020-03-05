resource "aws_route53_record" "alias_route53_record" {
  zone_id = "Z3UO86BYQAHMXT"
  name    = var.record_name
  type    = "A"

  alias {
    name                   = var.dest_record_name
    zone_id                = var.dest_zone_id
    evaluate_target_health = true
  }
}