locals {
        default_components_config_path = "${path.module}/default_components/linux/amazon_2023"

        ### Ansible CIS Pipeline uses gitlab repo to store scripts for use in the pipeline
        ### https://ansible-lockdown.readthedocs.io/en/latest/CIS/CIS_table.html
        default_components_cis = {
                ### IF this is assumable, then we can use default of: ""${path.module}/default_components/linux/amazon_2023/"
                ### otherwise we support override of all component object keys
                "100_install_dod_certs"   = { path    = "install_dod_certs.yml" }
                "200_configure_git"       = { path    = "configure_git.yml", parameters = {} }
                "300_oscap_scan"          = { path    = "oscap_scan.yml" ,parameters = { audit_bucket_name = aws_s3_bucket.audit.id}}
        }

        default_components_aws = {
                "100_install_dod_certs"   = { path    = "install_dod_certs.yml" }
                "200_enable_fips"         = { path    = "enable_fips.yml" }
                "300_setup_partitions"    = { path    = "setup_partitions.yml" }
                "400_aws_al2023_stig"     = { name = "aws:component/stig-build-linux/x.x.x",  parameters    = { Level = "High" } }
                "500_oscap_scan"          = { path    = "oscap_scan.yml", parameters = { audit_bucket_name = aws_s3_bucket.audit.id } }
        }

        default_components_awsdebug = {
                "100_install_dod_certs"   = { path    = "install_dod_certs.yml" }
                "200_enable_fips"         = { path    = "enable_fips.yml" }
                "300_setup_partitions"    = { path    = "setup_partitions.yml" }
                "400_aws_al2023_stig"     = { name = "aws:component/stig-build-linux/x.x.x", parameters    = { Level= "High" } }
                "500_oscap_scan"          = { path    = "oscap_scan.yml", parameters = { audit_bucket_name = aws_s3_bucket.audit.id } }
                "600_force_failure"       = { path    = "force_failure.yml" }
        }

        default_component_object = {  parameters         = {}
                                      platform           = "",
                                      description        = "",
                                      type               = "", ### will be either: 'managed' or 'custom'
                                      change_description = "",
                                      path               = "", ### path, version, name only valid with 'custom' type
                                      name               = "",
                                      version            = "1.0.0",
                                      arn                = ""  ### arn only valid with 'managed' type
        }

        default_components_map = {
                ""        = local.default_components_aws
                cis       = local.default_components_cis
                aws       = local.default_components_aws
                awsdebug  = local.default_components_awsdebug
        }

        default_components = lookup(local.default_components_map, var.default_component_set, local.default_components_cis)
}


### INPUT LOGIC FOR DEFAULTS
locals {

        ### included from variable INPUTS then overrides, otherwise default components are loaded based on
        included_components_config_path  = ( var.components_config_path != "") ? var.components_config_path : local.default_components_config_path

        included_components              = try( length(var.components_map) > 0 ?  var.components_map : local.default_components, local.default_components )

        merged_components_list   = { for component,attribute in local.included_components : component => merge(local.default_component_object,  attribute) }

        is_managed               = { for k, v in local.merged_components_list : k => length(regexall("^aws(?:-[a-z-]+)?:component/[a-z0-9-_]+/[a-z0-9x]+\\.[a-z0-9x]+\\.[a-z0-9x]+$", v.name)) > 0 }
}



data "aws_imagebuilder_image_recipe" "example" {
  arn = "arn:aws-us-gov:imagebuilder:us-gov-west-1:205415787579:image-recipe/dev-mbct-eks-stig-build-linux/x.x.x"
}

output "aws_imagebuilder_image_recipe_version" {
        value = data.aws_imagebuilder_image_recipe.example.version
}

locals {
        historical_recipe_version_found = ( data.aws_imagebuilder_image_recipe.example.version != "" ? (length(regexall("\\d+\\.\\d+\\.\\d+", data.aws_imagebuilder_image_recipe.example.version)) > 0 ? data.aws_imagebuilder_image_recipe.example.version : "${var.recipe_version}.0") : "${var.recipe_version}.0" )
        historical_recipe_major_number = tonumber(split( ".", ( local.historical_recipe_version_found ) )[0])
        historical_recipe_minor_number = tonumber(split( ".", ( local.historical_recipe_version_found ) )[1])
        historical_recipe_build_number = tonumber(split( ".", ( local.historical_recipe_version_found ) )[2])
}




# 1. Fetch all components owned by your account
data "aws_imagebuilder_components" "historical_versions" {
  owner = "Self"
}

locals {
        historical_aws_imagebuilder_components = [ for arn in data.aws_imagebuilder_components.historical_versions.arns : arn if length(regexall("component/", arn)) > 0 ]
        latest_component_versions =  { for comp_name, versions in { for arn in data.aws_imagebuilder_components.historical_versions.arns : split("/", arn)[1] => arn... } : comp_name => ( sort([ for arn in versions : split("/", arn)[2] ])[length(versions)-1] ) }
}
## 2. Filter the output to find all versions of a specific component by name
#output "historical_aws_imagebuilder_components" {
#        #value = data.data.aws_imagebuilder_components.historical_versions.arns
#        value = [ for arn in data.aws_imagebuilder_components.historical_versions.arns : arn if length(regexall("component/", arn)) > 0 ]
#}
#
output "latest_component_versions" {
  value = local.latest_component_versions
} 

locals {
  component_paths = { for component, attribute in local.included_components : component => attribute.path }
}

resource "null_resource" "version_bump_check" {
        for_each =  { for name,path in local.component_paths : name => path if path != "" }

        triggers = { 
                file_hash = filemd5("${path.module}/${local.included_components_config_path}/${each.value}") 
        }

}

output "null_resource_version_bump_check" {
        value = null_resource.version_bump_check
}


### CUSTOM COMPONENT OBJECT LIST
locals {
                prepared_components_list = { for component, attribute in local.merged_components_list : 

                                               component => { 
                                                ###                     if true then managed, else custom
                                                                type = local.is_managed[component] ? "managed" : "custom"

                                                                name = local.is_managed[component] ? "aws_managed_${component}" : substr(component, 4, -1)


                                                                platform = try(local.imagebuilder_recipe_parent_images[var.recipe_parent_image_archetype].platform, local.imagebuilder_recipe_parent_images["AL2023"].platform)
                                                                

                                                                arn  = ( local.is_managed[component] ? "arn:aws-us-gov:imagebuilder:${var.globals["region"]}:${attribute.name}" 
                                                                                                     : "arn:aws-us-gov:imagebuilder:${var.globals["region"]}:${var.globals["account_id"]}:component/${lower(replace("${var.globals["aws_resource_nametag_prefix"]}_${var.image_name}_${substr(component, 4, -1)}", "_", "-"))}/${attribute.version != "" ? attribute.version : var.recipe_version}" )
                                                                                                                                        
                                                                path               = ( local.is_managed[component] ? "" : attribute.path != "" ? attribute.path
                                                                                                                       : "${local.included_components_config_path}/${substr(component, 4, -1)}.yml")

                                                                version            = ( local.is_managed[component] ? "" : length(regexall("\\d+\\.\\d+\\.\\d+", attribute.version)) > 0 ? ( null_resource.version_bump_check["${lower(replace("${var.globals["aws_resource_nametag_prefix"]}_${var.image_name}_${substr(component, 4, -1)}", "_", "-"))}"].triggers.file_hash ? join(".", [ tonumber(split(".", attribute.version)[0]), tonumber(split(".", attribute.version)[1]),tonumber(split(".", attribute.version)[2])+1 ]) : attribute.version ) : "1.0.0" ) ### needs check on version x.y.z 

                                                                description        =( local.is_managed[component] ? "" : attribute.description != "" ? attribute.description  
                                                                                                                        : "" )

                                                                change_description =( local.is_managed[component] ? "" : attribute.change_description != "" ? attribute.change_description 
                                                                                                                        : "")

                                                                parameters         = try(attribute.parameters, {} )
                                                        }
        }

}

data "aws_caller_identity" "current" {}
data "aws_iam_account_alias" "current" {}

data "aws_key_pair" "account_pem" {
        filter {
                name   = "tag:environment"
                values = [var.globals["account_environment"], var.globals["environment_shorthand"]]
        }
        filter {
                name   = "tag:service"
                values = ["EC2"]
        }
        filter {
                name   = "tag:secret_type"
                values = ["PEM RSA Private Key"]
        }
}



output "included_components_config_path" {
        value = local.included_components_config_path
}

output "included_components" {
        value = local.included_components
}

output "merged_components_list" {
        value = local.merged_components_list
}

output "prepared_components_list" {
        value = local.prepared_components_list
}


output "default_components" {
        value = local.default_components
}
