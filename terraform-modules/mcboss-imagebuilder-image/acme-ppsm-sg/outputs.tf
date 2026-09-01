output "security_groups" {
  description = "Map of security group names to their full objects"
  value       = aws_security_group.sg
}

output "raw_csv_rules" {
  description = "Loaded CSV with interpolated values from Locals"
  value       = local.rules
}

output "sg_names" {
  description = "Set/List of Security Group Names from Locals"
  value       = local.sg_names
}

output "ingress_rules" {
  description = "Map of Ingress Rules for Security Groups from Locals"
  value       = local.ingress_rules
}

output "egress_rules" {
  description = "Map of Egress Rules for Security Groups from Locals"
  value       = local.egress_rules
}
