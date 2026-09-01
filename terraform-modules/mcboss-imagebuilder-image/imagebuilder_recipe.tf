resource "aws_imagebuilder_image_recipe" "this" {
        name         = "${var.globals["aws_resource_nametag_prefix"]}_${var.image_name}"
        parent_image = local.recipe_parent_image
        version      = var.recipe_version

        lifecycle {
                create_before_destroy = true
                ignore_changes = [ tags, tags_all, block_device_mapping ]
        }

        systems_manager_agent { uninstall_after_build = false }


        dynamic "block_device_mapping" { ### Inject Block Device Mappings if they exist
                for_each = var.block_device_mappings

                content {
                        device_name = block_device_mapping.value.device_name
                        ebs {
                                delete_on_termination = block_device_mapping.value.delete_on_termination
                                volume_size           = block_device_mapping.value.volume_size
                                volume_type           = block_device_mapping.value.volume_type
                        }
                }
        }

        dynamic "component" { ### Inject Components if they exist
                for_each = local.prepared_components_list

                content {
                        component_arn = component.value.arn
                        dynamic "parameter" { ### Inject Parameters if they exist, per Component
                                for_each = component.value.parameters != null ? component.value.parameters : {}

                                content {
                                        name  = parameter.key
                                        value = parameter.value
                                }
                        }
                }
        }

        depends_on = [ aws_imagebuilder_component.prepared_components ]
}
