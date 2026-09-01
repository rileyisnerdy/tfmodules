resource "aws_imagebuilder_image_pipeline" "cron" {
        count = var.cron_pipeline_create_toggle ? 1 : 0

        depends_on = [ aws_imagebuilder_image_recipe.this ]

        name                             = "${var.globals["aws_resource_nametag_prefix"]}_${var.image_name}_cron"
        status                           = var.cron_pipeline_status
        image_recipe_arn                 = aws_imagebuilder_image_recipe.this.arn
        infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.this.arn
        enhanced_image_metadata_enabled  = true
 
        schedule {
                schedule_expression                 = ( var.cron_pipeline_schedule_expression == "" ? "cron(0 9 ? * mon)" : var.cron_pipeline_schedule_expression )
                pipeline_execution_start_condition  = ( var.cron_pipeline_execute_condition == "" ? "EXPRESSION_MATCH" : var.cron_pipeline_execute_condition )
        }

        # Dynamically add the image_tests_configuration block only if var.cron_pipeline_tests_toggle is 'true'
        dynamic "image_tests_configuration" {
                for_each = var.cron_pipeline_tests_toggle != "" ? [1] : []
                content {
                        image_tests_enabled = var.cron_pipeline_tests_toggle
                        timeout_minutes     = var.cron_pipeline_tests_timeout
                }
        }

        lifecycle {
                ignore_changes = [ tags,
                                   tags_all ]
        }
}