resource "aws_imagebuilder_infrastructure_configuration" "this" {
        name                  = "${var.globals["aws_resource_nametag_prefix"]}_${var.image_name}"
        instance_profile_name = aws_iam_instance_profile.this.name
        subnet_id             = var.globals["vpc_subnet_workloads_zone1_id"]

        security_group_ids = concat([for sg in values(module.ppsm.security_groups) : sg.id], var.additional_security_group_ids)
        terminate_instance_on_failure = var.terminate_instance_on_failure
        key_pair = data.aws_key_pair.account_pem.key_name
}