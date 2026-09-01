locals {

        al2023_parent_image_name = "/aws/service/eks/optimized-ami/${var.eks_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"

        imagebuilder_recipe_parent_images = {
                "AL2023" = { ami_name = local.al2023_parent_image_name
                             ami_id   = data.aws_ssm_parameter.base_amazonlinux_eks_ami_id.value
                             platform = "Linux"
                           }
                "RHEL9"  = {}
        }

        recipe_parent_image = (var.recipe_parent_image != "") ? (var.recipe_parent_image) : ( try(local.imagebuilder_recipe_parent_images[var.recipe_parent_image_archetype].ami_id, local.imagebuilder_recipe_parent_images["AL2023"].ami_id) )
}



### fetch the latest EKS Optimized Amazon Linux AMI ID from SSM
###
### FIXME: this means the module only works with Amazon Linux EKS Optimized for the time being
###             we will need to support input, or support picking a predefined value below in the future
data "aws_ssm_parameter" "base_amazonlinux_eks_ami_id" {
        name = local.al2023_parent_image_name
}

output "aws_ssm_parameter_base_amazonlinux_eks_ami_id" {
        value = data.aws_ssm_parameter.base_amazonlinux_eks_ami_id.value
}