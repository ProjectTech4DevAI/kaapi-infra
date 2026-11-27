import {
  to = module.vpc.aws_vpc.this
  id = var.vpc_id
}

# Adopts every existing instance listed in ec2_instances (no-op once it is in state)
import {
  for_each = var.ec2_instances
  to       = module.ec2.aws_instance.this[each.key]
  id       = local.ec2_instance_ids[each.key]
}
