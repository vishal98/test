resource "random_string" "app_keystore_password" {
  length  = 16
  special = false
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "cert" {
  key_algorithm         = "RSA"
  private_key_pem       = "${tls_private_key.key.private_key_pem}"
  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = ["*.${var.region}.elb.amazonaws.com"]

  subject {
    common_name  = "*.${var.region}.elb.amazonaws.com"
    organization = "TUI AG"
    province     = "Niedersachsen"
    country      = "DE"
  }
}

resource "tls_self_signed_cert" "public_cert" {
  key_algorithm         = "RSA"
  private_key_pem       = "${tls_private_key.key.private_key_pem}"
  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = ["*.${var.region}.elb.amazonaws.com"]

  subject {
    common_name  = "*.${var.region}.elb.amazonaws.com"
    organization = "TUI AG"
    province     = "Niedersachsen"
    country      = "DE"
  }
}
