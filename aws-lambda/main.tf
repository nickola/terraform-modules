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
  source_dir  = var.source_directory
  source_file = var.source_file
  output_path = "_lambda/lambda-${var.name}.zip"
  excludes    = var.source_file != null ? null : setunion(coalesce(var.source_directory_excludes_always, []), coalesce(var.source_directory_excludes, []))
}

resource "aws_lambda_function" "lambda" {
  role = aws_iam_role.lambda_role.arn

  function_name = var.name
  architectures = [var.architecture]
  runtime       = var.runtime
  handler       = var.handler
  memory_size   = var.memory
  timeout       = var.timeout

  filename         = "_lambda/lambda-${var.name}.zip"
  source_code_hash = data.archive_file.lambda_archive.output_base64sha256

  environment {
    variables = var.environment
  }
}

resource "aws_lambda_function_url" "lambda_url" {
  count = var.url_enabled ? 1 : 0

  function_name      = aws_lambda_function.lambda.function_name
  authorization_type = "NONE"
}

# Log group
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = var.log_retention
}

data "aws_iam_policy_document" "lambda_log_group_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.lambda_log_group.arn}:*"]
  }
}

resource "aws_iam_policy" "lambda_log_group_policy" {
  name   = "${var.name}-lambda-log-group-policy"
  policy = data.aws_iam_policy_document.lambda_log_group_policy_document.json
}

resource "aws_iam_role_policy_attachment" "lambda_log_group_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_log_group_policy.arn
}

# Custom policy
resource "aws_iam_policy" "lambda_policy" {
  count = var.policy != null ? 1 : 0

  name   = "${var.name}-lambda-policy"
  policy = var.policy
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  count = var.policy != null ? 1 : 0

  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachments" {
  for_each = var.policy_attachments != null ? toset(var.policy_attachments) : []

  role       = aws_iam_role.lambda_role.name
  policy_arn = each.value
}

# Output
output "role" {
  value = aws_iam_role.lambda_role.arn
}

output "url" {
  value = var.url_enabled ? aws_lambda_function_url.lambda_url[0].function_url : ""
}

output "status" {
  value = {
    lambda_arn           = aws_lambda_function.lambda.arn
    lambda_url           = var.url_enabled ? aws_lambda_function_url.lambda_url[0].function_url : ""
    lambda_runtime       = aws_lambda_function.lambda.runtime
    lambda_memory_size   = aws_lambda_function.lambda.memory_size
    lambda_architectures = aws_lambda_function.lambda.architectures
  }
}
