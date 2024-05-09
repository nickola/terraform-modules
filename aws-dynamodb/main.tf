resource "aws_dynamodb_table" "dynamodb_table" {
  name           = var.table
  billing_mode   = var.billing_mode
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = var.hash_key

  tags = {
    Name = var.table
  }

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }
}

output "status" {
  value = {
    table          = aws_dynamodb_table.dynamodb_table.name
    table_class    = aws_dynamodb_table.dynamodb_table.table_class
    table_hash_key = aws_dynamodb_table.dynamodb_table.hash_key
  }
}
