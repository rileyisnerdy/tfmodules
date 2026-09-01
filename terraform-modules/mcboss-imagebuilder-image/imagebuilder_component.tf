resource "aws_imagebuilder_component" "prepared_components" {
        for_each =  { for key, value in local.prepared_components_list : key => value if value.type == "custom" }

        name = lower(replace("${var.globals["aws_resource_nametag_prefix"]}_${var.image_name}_${each.value.name}", "_", "-"))
        platform = try(each.value.platform, "Linux")  
        version  = each.value.version

        ### COMPONENT DESCRIPTION
        description = each.value.description == "" ? null : each.value.description 
        ### VERSION AND CHANGE DESCRIPTION FOR THIS SPECIFIC RELEASE x.y.z
        change_description = each.value.change_description == "" ? null : each.value.change_description

        data = ( length(regexall("^aws", each.value.name)) > 0 ) ?  null : ( can(each.value.parameters) ? templatefile("${path.module}/${local.included_components_config_path}/${each.value.name}.yml", each.value.parameters) 
                                                                                                         : file("${path.module}/${local.included_components_config_path}/${each.value.name}.yml"))

}

