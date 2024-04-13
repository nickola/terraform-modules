data "aws_caller_identity" "identity" {}
data "aws_region" "region" {}

output "status" {
  value = {
    aws_account            = data.aws_caller_identity.identity.account_id
    aws_account_user       = data.aws_caller_identity.identity.arn
    aws_region             = data.aws_region.region.id
    aws_region_description = data.aws_region.region.description
  }
}
