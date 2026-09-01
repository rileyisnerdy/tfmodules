module "imagebuilder_eks_stig_build_linux" {
        source                 = "./terraform-modules/acme-imagebuilder-image"
  ### REQUIRED VALUES
        globals                = local.globals
        image_name             = var.imagebuilder_eks_stig_build_linux_image_name  ### FIXME: check allowed values

        eks_version            = var.imagebuilder_eks_stig_build_linux_eks_version
        recipe_version         = var.imagebuilder_eks_stig_build_linux_recipe_version
        
        components_config_path = var.imagebuilder_eks_stig_build_linux_components_config_path

  ### EXCLUSIVE VALUES, ONE OR THE OTHER MUST BE SET
        recipe_parent_image_archetype = var.imagebuilder_eks_stig_build_linux_recipe_parent_image_archetype
        #recipe_parent_image = data.aws_ssm_parameter.base_amazonlinux_eks_ami_id.value

  ### OPTIONAL, CONVERT TO
        terminate_instance_on_failure    = false

        block_device_mappings            = var.imagebuilder_eks_stig_build_linux_block_device_mappings
       #components_map                   = var.imagebuilder_eks_stig_build_linux_components_map
        default_component_set = "aws"
        
        ondemand_pipeline_create_toggle  = true         # defaults to false
        additional_security_group_ids = [ local.acme_provided["integration_with_acme_scca_sg_id"] ]
}

#output "aws_imagebuilder_image_recipe_version" {
#        value = module.imagebuilder_eks_stig_build_linux.aws_imagebuilder_image_recipe_version
#}

output "null_resource_version_bump_check" {
        value = module.imagebuilder_eks_stig_build_linux.null_resource_version_bump_check
}

#
#output "latest_component_versions" {
#        value = module.imagebuilder_eks_stig_build_linux.latest_component_versions
#}



locals {
        globals = merge(local.acme_provided, {})
        #                                       { placeholder_key1         = var.placeholder_value1,
        #                                         placeholder_key2         = var.placeholder_value2
        #        }
        #)
}

### fetch the latest EKS Optimized Amazon Linux AMI ID from SSM
###
### FIXME: this means the module only works with Amazon Linux EKS Optimized for the time being
###             we will need to support input, or support picking a predefined value below in the future
data "aws_ssm_parameter" "base_amazonlinux_eks_stig_build_linux_ami_id" {
        name = "/aws/service/eks/optimized-ami/${var.imagebuilder_eks_stig_build_linux_eks_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
}

#     ## DEBUG PIPELINE ##
#     module "imagebuilder_eks_debug" {
#             source                 = "./terraform-modules/acme-imagebuilder-image"
#       ### REQUIRED VALUES
#             globals                = local.globals
#             image_name             = var.imagebuilder_eks_debug_image_name  ### FIXME: check allowed values
#     
#             eks_version            = var.imagebuilder_eks_debug_eks_version
#             recipe_version         = var.imagebuilder_eks_debug_recipe_version
#             
#             components_config_path = var.imagebuilder_eks_debug_components_config_path
#     
#       ### EXCLUSIVE VALUES, ONE OR THE OTHER MUST BE SET
#             recipe_parent_image_archetype = var.imagebuilder_eks_debug_recipe_parent_image_archetype
#             #recipe_parent_image = data.aws_ssm_parameter.base_amazonlinux_eks_ami_id.value
#     
#       ### OPTIONAL, CONVERT TO
#             terminate_instance_on_failure    = false
#     
#             block_device_mappings            = var.imagebuilder_eks_debug_block_device_mappings
#            # components_map                   = var.imagebuilder_eks_debug_components_map
#                 default_component_set = "aws"
#                 
#             ondemand_pipeline_create_toggle  = true         # defaults to false
#     }
#     
#     ### fetch the latest EKS Optimized Amazon Linux AMI ID from SSM
#     ###
#     ### FIXME: this means the module only works with Amazon Linux EKS Optimized for the time being
#     ###             we will need to support input, or support picking a predefined value below in the future
#     data "aws_ssm_parameter" "base_amazonlinux_eks_ami_id" {
#             name = "/aws/service/eks/optimized-ami/${var.imagebuilder_eks_debug_eks_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
#     }
