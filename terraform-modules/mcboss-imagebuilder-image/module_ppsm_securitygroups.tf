module "ppsm" {
    #source = "git::ssh://git@git.acme.usmc.mil/terraform-modules/acme-ppsm-sg.git?ref=v1.0.2"
    source = "./acme-ppsm-sg"
    vpc_id = var.globals["vpc_id"]
    aws_resource_nametag_prefix = var.globals["aws_resource_nametag_prefix"]

    #rules_path  = "ppsm/imagebuilder_sg.csv"
    rules_file  = templatefile("${path.module}/ppsm/imagebuilder_sg.csv", {image_name = var.image_name}) ### FIXMEgit status
    
    #globals = local.globals
}


#locals {
#    globals = {
#        acme_vdms_activedirectory_zone1_cidr = "${var.globals[acme_vdms_activedirectory_zone1_ip]}/32"
#        acme_vdms_activedirectory_zone2_cidr = "${var.globals[acme_vdms_activedirectory_zone2_ip]}/32"
#        acme_vdms_workspaces_zone1_cidr      = "10.6.206.0/24"
#        acme_vdms_workspaces_zone2_cidr      = "10.6.207.0/24"
#        acme_vdss_f5_bgp_zone1_cidr          = var.globals["acme_vdss_f5_bgp_zone1_cidr"]
#        acme_vdss_f5_bgp_zone2_cidr          = var.globals["acme_vdss_f5_bgp_zone2_cidr"]
#
#        workloads_zone1_cidr                   = var.globals["vpc_subnet_workloads_zone1_cidr"]
#        workloads_zone2_cidr                   = var.globals["vpc_subnet_workloads_zone2_cidr"]
#        workloads_zone3_cidr                   = var.globals["vpc_subnet_workloads_zone3_cidr"]
#    }
#}
#
#output "module_sg_security_groups" {
#  description = "Map of security group names to their full objects"
#  value       = module.sg.security_groups
#}
#
#output "module_sg_raw_csv_rules" {
#  description = "Loaded CSV with interpolated values from Locals"
#  value       = module.sg.raw_csv_rules
#}
#
#output "module_sg_sg_names" {
#  description = "Set/List of Security Group Names from Locals"
#  value       = module.sg.sg_names
#}
#
#output "module_sg_ingress_rules" {
#  description = "Map of Ingress Rules for Security Groups from Locals"
#  value       = module.sg.ingress_rules
#}
#
#output "module_sg_egress_rules" {
#  description = "Map of Egress Rules for Security Groups from Locals"
#  value       = module.sg.egress_rules
#}