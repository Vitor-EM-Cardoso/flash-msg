resource "aws_dynamodb_table" "vault" {
  name         = "flash-msg-vault"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "secret_id"

  attribute {
    name = "secret_id"
    type = "S"
  }

  # The Magic Feature: Auto-expiry
  ttl {
    attribute_name = "expiry_timestamp"
    enabled        = true
  }
}
