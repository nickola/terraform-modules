locals {
  regex_variable = "[^{}]+"
  regex_variable_outside = "(\\{\\{${local.regex_variable}\\}\\})"
  regex_variable_inside = "^\\{\\{(${local.regex_variable})\\}\\}"
  divider = "[[<<__\u0000_TF_TEMPLATE_DIVIDER_\u0000__>>]]"

  text = file(var.file)
  marked_text = replace(local.text, "/${local.regex_variable_outside}/", "${local.divider}$1${local.divider}")
  divided_text = split(local.divider, local.marked_text)

  updated_text = [
    for text in local.divided_text : (
      can(regex("^${local.regex_variable_inside}$", text)) ?
      lookup(var.data, trimspace(replace(text, "/^${local.regex_variable_inside}$/", "$1")), "") :
      text
    )
  ]

  rendered = join("", local.updated_text)
}

# Outputs
output "rendered" {
  value = local.rendered
}
