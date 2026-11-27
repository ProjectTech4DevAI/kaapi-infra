data "aws_instance" "existing" {
  for_each = var.instances

  instance_id = var.instance_ids[each.key]
}

resource "aws_instance" "this" {
  for_each = var.instances

  ami                  = data.aws_instance.existing[each.key].ami
  instance_type        = each.value.instance_type
  iam_instance_profile = each.value.iam_instance_profile

  tags = merge(each.value.tags, { Name = "${var.name_prefix}-${each.value.name}" })

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [ami, user_data, user_data_base64]
  }
}
