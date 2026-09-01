variable "imagebuilder_eks_debug_image_name" {
        description = "(Required)"
        type        = string
        #default = "eks_debug"
}

variable "imagebuilder_eks_debug_components_config_path" {
        description = "(Required)"
        type        = string
        #default = "./imagebuilder_pipelines/linux/amazon_2023/eks_debug"
        #default = "./eks_debug"
}

variable "imagebuilder_eks_debug_recipe_version" {
        description = "(Required)"
        type        = string
        #default = "1.0.0"
}

variable "imagebuilder_eks_debug_eks_version" {
        description = "(Required)"
        type        = string
        #default = "1.35"
}

variable "imagebuilder_eks_debug_recipe_parent_image_archetype" {
        description = "(Required)"
        type        = string
        #default = "AL2023"
}

variable "imagebuilder_eks_debug_components_map" {
        description = "(Required) List of image builder components"
        #type = list( object({   type       = string
        #                        path       = string
        #                        version    = string
        #                        name       = string
        #                        arn        = string
        #                        parameters = list( object({ name  = string
        #                                                    value = string
        #                                           })
        #                        )
        #             })
        #)
}

variable "imagebuilder_eks_debug_block_device_mappings" {
        description = "(Optional) Rich Value Type List of EBS block devices to attach to the image recipe"
        #type = list(object({
        #        device_name           = string
        #        delete_on_termination = bool
        #        volume_size           = number
        #        volume_type           = string
        #}))
        #default = [
        #        {
        #                device_name           = "/dev/xvda"
        #                delete_on_termination = true
        #                volume_size           = 100
        #                volume_type           = "gp3"
        #        },
        #        {
        #                device_name           = "/dev/sdb"
        #                delete_on_ation = true
        #                volume_size           = 150 
        #                volume_type           = "gp3"
        #        }
        #]
}



## STIG BUILD LINUX ##
variable "imagebuilder_eks_stig_build_linux_image_name" {
        description = "(Required)"
        type        = string
        #default = "eks_stig_build_linux"
}

variable "imagebuilder_eks_stig_build_linux_components_config_path" {
        description = "(Required)"
        type        = string
        #default = "./imagebuilder_pipelines/linux/amazon_2023/eks_stig_build_linux"
        #default = "./eks_stig_build_linux"
}

variable "imagebuilder_eks_stig_build_linux_recipe_version" {
        description = "(Required)"
        type        = string
        #default = "1.0.0"
}

variable "imagebuilder_eks_stig_build_linux_eks_version" {
        description = "(Required)"
        type        = string
        #default = "1.35"
}

variable "imagebuilder_eks_stig_build_linux_recipe_parent_image_archetype" {
        description = "(Required)"
        type        = string
        #default = "AL2023"
}

variable "imagebuilder_eks_stig_build_linux_components_map" {
        description = "(Required) List of image builder components"
        #type = list( object({   type       = string
        #                        path       = string
        #                        version    = string
        #                        name       = string
        #                        arn        = string
        #                        parameters = list( object({ name  = string
        #                                                    value = string
        #                                           })
        #                        )
        #             })
        #)
}

variable "imagebuilder_eks_stig_build_linux_block_device_mappings" {
        description = "(Optional) Rich Value Type List of EBS block devices to attach to the image recipe"
        #type = list(object({
        #        device_name           = string
        #        delete_on_termination = bool
        #        volume_size           = number
        #        volume_type           = string
        #}))
        #default = [
        #        {
        #                device_name           = "/dev/xvda"
        #                delete_on_termination = true
        #                volume_size           = 100
        #                volume_type           = "gp3"
        #        },
        #        {
        #                device_name           = "/dev/sdb"
        #                delete_on_ation = true
        #                volume_size           = 150 
        #                volume_type           = "gp3"
        #        }
        #]
}