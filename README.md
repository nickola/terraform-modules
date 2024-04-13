# Terraform Modules

Different Terraform modules.

## AWS Status

Terraform code:
```terraform
module "aws_status" { source = "./aws-status" }
output "aws_status" { value = module.aws_status.status }
```

Output:
```terraform
aws_status = {
  "aws_account" = "123456789012"
  "aws_account_user" = "arn:aws:iam::123456789012:user/name"
  "aws_region" = "us-east-1"
  "aws_region_description" = "US East (N. Virginia)"
}
```

## AWS S3

Terraform code:
```terraform
module "aws_s3" {
  source = "./aws-s3"

  bucket      = "test-bucket"
  public_read = true
}

output "aws_s3" { value = module.aws_s3.status }
```

Output:
```terraform
s3_status = {
  "bucket_arn" = "arn:aws:s3:::test-bucket"
  "bucket_domain" = "test-bucket.s3.amazonaws.com"
  "bucket_public_read" = true
}
```

## AWS Lambda

Python code (`test.py`):
```python
def lambda_handler(event, context):
  return {'statusCode': 200, 'body': "Hello World"}
```

Terraform code:
```terraform
module "aws_lambda" {
  source = "./aws-lambda"

  name        = "test-lambda"
  runtime     = "python3.9"
  handler     = "test.lambda_handler"
  source_file = "${path.module}/test.py"
  url_enabled = true
}

output "aws_lambda" { value = module.aws_lambda.status }
```

Output:
```terraform
lambda = {
  "lambda_arn" = "arn:aws:lambda:us-east-1:123456789012:function:test-lambda"
  "lambda_url" = "https://abcdefghijklmnopqrstuvwxyz123456.lambda-url.us-east-1.on.aws/"
}
```
