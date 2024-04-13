resource "aws_iam_role" "lambda_role" {
  name = "${var.name}-lambda-role"

  tags = {
    Name = "${var.name}-lambda-role"
  }

  assume_role_policy = <<-DATA
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "lambda.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
  DATA
}

data "archive_file" "lambda_archive" {
  type        = "zip"
  source_file = var.source_file
  output_path = "_lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  role = aws_iam_role.lambda_role.arn

  function_name = var.name
  runtime       = var.runtime
  handler       = var.handler

  filename         = "_lambda.zip"
  source_code_hash = data.archive_file.lambda_archive.output_base64sha256
}

resource "aws_lambda_function_url" "lambda_url" {
  count = var.url_enabled ? 1 : 0

  function_name      = aws_lambda_function.lambda.function_name
  authorization_type = "NONE"
}

# Output
output "url" {
  value = var.url_enabled ? aws_lambda_function_url.lambda_url[0].function_url : ""
}

output "status" {
  value = {
    lambda_arn = aws_lambda_function.lambda.arn
    lambda_url = var.url_enabled ? aws_lambda_function_url.lambda_url[0].function_url : ""
  }
}
