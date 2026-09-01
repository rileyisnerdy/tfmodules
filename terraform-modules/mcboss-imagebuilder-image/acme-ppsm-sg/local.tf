locals {
  rules = [
    for r in module.validation_of_rules.rules : {
      rule_id        = trimspace(r.rule_id)
      sg_name        = trimspace(r.sg_name)
      type           = lower(trimspace(r.type))
      protocol       = lower(trimspace(r.protocol))
      from_port      = trimspace(r.from_port) != "" ? tonumber(r.from_port) : null
      to_port        = trimspace(r.to_port) != "" ? tonumber(r.to_port) : null
      cidr_ipv4      = trimspace(r.cidr_ipv4)
      cidr_ipv6      = trimspace(r.cidr_ipv6)
      source_sg_name = trimspace(r.source_sg_name)
      prefix_list_id = trimspace(r.prefix_list_id)
      description    = trimspace(r.description)
    }
  ]

  sg_names      = toset([for r in local.rules : r.sg_name])
  ingress_rules = { for r in local.rules : r.rule_id => r if r.type == "ingress" }
  egress_rules  = { for r in local.rules : r.rule_id => r if r.type == "egress" }



}