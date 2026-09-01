module "imagebuilder_eks_debug" {
        source                = "./terraform-modules/acme-imagebuilder-image"
  ### REQUIRED VALUES
          globals = local.globals
        image_name            = var.imagebuilder_eks_debug_image_name  ### FIXME: check allowed values

        eks_version           = var.imagebuilder_eks_debug_eks_version
        recipe_version        = var.imagebuilder_eks_debug_recipe_version
        
        components_config_path = var.imagebuilder_eks_debug_components_config_path

  ### EXCLUSIVE VALUES, ONE OR THE OTHER MUST BE SET
        recipe_parent_image_archetype = var.imagebuilder_eks_debug_recipe_parent_image_archetype
        #recipe_parent_image = data.aws_ssm_parameter.base_amazonlinux_eks_ami_id.value

  ### OPTIONAL, CONVERT TO
        terminate_instance_on_failure = false

        block_device_mappings = var.imagebuilder_eks_debug_block_device_mappings
        components_map = var.imagebuilder_eks_debug_components_map

        ondemand_pipeline_create_toggle  = true         # defaults to false
        #ondemand_pipeline_status        = "DISABLED"   # defaults to "ENABLED"
        #ondemand_pipeline_tests_toggle  = true         # defaults to false
        #ondemand_pipeline_tests_timeout = "60"         # defaults to 720 (req: 60 - 1440)

        #cron_pipeline_create_toggle     = true         # defaults to false
        #cron_pipeline_status            = "DISABLED"   # defaults to "ENABLED"
        #cron_pipeline_schedule_expression = "cron(0 0 ? * fri)" # defaults to "cron(0 9 ? * mon)"
        #cron_pipeline_execute_condition = "EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE" # defaults to "EXPRESSION_MATCH_ONLY" ( EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE or EXPRESSION_MATCH_ONLY)
        #cron_pipeline_tests_toggle      = true         # defaults to false
        #cron_pipeline_tests_timeout     = "60"         # defaults to 720 (req: 60 - 1440)
}

# locals {
#         globals = merge(local.acme_provided, {})
#         #                                       { placeholder_key1         = var.placeholder_value1,
#         #                                         placeholder_key2         = var.placeholder_value2
#         #        }
#         #)
# }






### fetch the latest EKS Optimized Amazon Linux AMI ID from SSM
###
### FIXME: this means the module only works with Amazon Linux EKS Optimized for the time being
###             we will need to support input, or support picking a predefined value below in the future
data "aws_ssm_parameter" "base_amazonlinux_eks_ami_id" {
        name = "/aws/service/eks/optimized-ami/${var.imagebuilder_eks_debug_eks_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
}
