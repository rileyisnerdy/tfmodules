resource "aws_imagebuilder_image_pipeline" "ondemand" {
        count = var.ondemand_pipeline_create_toggle ? 1 : 0

        depends_on = [ aws_imagebuilder_image_recipe.this ]

        name                             = "${var.globals["aws_resource_nametag_prefix"]}_${var.image_name}_ondemand"
        status                           = var.ondemand_pipeline_status
        image_recipe_arn                 = aws_imagebuilder_image_recipe.this.arn
        infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.this.arn
        enhanced_image_metadata_enabled  = true
 
        # Dynamically add the image_tests_configuration block only if var.ondemand_pipeline_tests_toggle is 'true'
        ### Always emitted. Omitting the block makes AWS default image tests to
        ### enabled, so the toggle has to be sent explicitly to turn them off.
        image_tests_configuration {
                image_tests_enabled = var.ondemand_pipeline_tests_toggle
                timeout_minutes     = var.ondemand_pipeline_tests_timeout
        }

        lifecycle {
                ignore_changes = [ tags,
                                   tags_all ]
        }
}
