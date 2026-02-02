resource "aws_budgets_budget" "budget" {
  name              = var.name
  budget_type       = var.type
  time_unit         = var.time
  limit_unit        = var.limit_unit
  limit_amount      = var.limit

  dynamic "notification" {
    for_each = (var.preliminary_alert == true && var.preliminary_alert_percent != null) ? ["+"] : []

    content {
      comparison_operator = "GREATER_THAN"
      threshold_type      = "PERCENTAGE"
      notification_type   = "ACTUAL"
      threshold           = var.preliminary_alert_percent

      subscriber_email_addresses = var.emails
    }
  }

  notification {
    comparison_operator = "GREATER_THAN"
    threshold_type      = "PERCENTAGE"
    notification_type   = "ACTUAL"
    threshold           = 100

    subscriber_email_addresses = var.emails
  }

  notification {
    comparison_operator = "GREATER_THAN"
    threshold_type      = "PERCENTAGE"
    notification_type   = "FORECASTED"
    threshold           = 100

    subscriber_email_addresses = var.emails
  }
}

# Outputs
output "budget" {
  value = aws_budgets_budget.budget
}
