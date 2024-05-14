resource "aws_iam_user" "user" {
  name = var.name
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy" "user_policy" {
  name   = "${var.name}-policy"
  user   = aws_iam_user.user.name
  policy = var.policy
}

output "status" {
  value = {
    user_name       = aws_iam_access_key.user.user
    user_key_id     = aws_iam_access_key.user.id
    user_key_secret = nonsensitive(aws_iam_access_key.user.secret)
  }
}
