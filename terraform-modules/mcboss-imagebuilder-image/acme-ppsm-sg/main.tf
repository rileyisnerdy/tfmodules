resource "aws_security_group" "sg" {
  for_each = local.sg_names

  name        = "${var.aws_resource_nametag_prefix}_${each.value}"
  description = "Managed by Terraform from PPSM"
  vpc_id      = var.vpc_id

  tags = {
    Name      = "${var.aws_resource_nametag_prefix}_${each.value}"
  }

}

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  for_each = local.ingress_rules

  security_group_id            = aws_security_group.sg[each.value.sg_name].id
  ip_protocol                  = each.value.protocol
  from_port                    = each.value.protocol == "-1" ? null : each.value.from_port
  to_port                      = each.value.protocol == "-1" ? null : each.value.to_port
  cidr_ipv4                    = each.value.cidr_ipv4 != "" ? try(var.globals[each.value.cidr_ipv4], each.value.cidr_ipv4) : null
  cidr_ipv6                    = each.value.cidr_ipv6 != "" ? each.value.cidr_ipv6 : null
  referenced_security_group_id = each.value.source_sg_name != "" ? ( can(regex("^sg-[a-f0-9]+$", var.globals[each.value.source_sg_name])) ? var.globals[each.value.source_sg_name]  : aws_security_group.sg[each.value.source_sg_name].id) : null
  prefix_list_id               = each.value.prefix_list_id != "" ? try(var.globals[each.value.prefix_list_id], each.value.prefix_list_id) : null
  description                  = each.value.description
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  for_each = local.egress_rules

  security_group_id            = aws_security_group.sg[each.value.sg_name].id
  ip_protocol                  = each.value.protocol
  from_port                    = each.value.protocol == "-1" ? null : each.value.from_port
  to_port                      = each.value.protocol == "-1" ? null : each.value.to_port
  cidr_ipv4                    = each.value.cidr_ipv4 != "" ? try(var.globals[each.value.cidr_ipv4], each.value.cidr_ipv4) : null
  cidr_ipv6                    = each.value.cidr_ipv6 != "" ? each.value.cidr_ipv6 : null
  referenced_security_group_id = each.value.source_sg_name != "" ? ( can(regex("^sg-[a-f0-9]+$", var.globals[each.value.source_sg_name])) ? var.globals[each.value.source_sg_name]  : aws_security_group.sg[each.value.source_sg_name].id) : null
  prefix_list_id               = each.value.prefix_list_id != "" ? try(var.globals[each.value.prefix_list_id], each.value.prefix_list_id) : null
  description                  = each.value.description
}