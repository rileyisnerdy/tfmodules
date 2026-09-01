locals {
        default_components_config_path = "${path.module}/default_components/linux/amazon_2023"

        ### Deterministic audit bucket name.
        ### Derived purely from input variables (NOT from aws_s3_bucket.audit.id) so that any local
        ### feeding a for_each / dynamic block stays known at plan time. Must stay in sync with the
        ### bucket argument in component_s3_bucket_audit.tf, which references this same local.
        audit_bucket_name = "${lower(replace(var.globals["aws_resource_nametag_prefix"], "_", "-"))}-imagebuilder-${lower(replace(var.image_name, "_", "-"))}-audit"

        ### Ansible CIS Pipeline uses gitlab repo to store scripts for use in the pipeline
        ### https://ansible-lockdown.readthedocs.io/en/latest/CIS/CIS_table.html
        default_components_cis = {
                ### IF this is assumable, then we can use default of: ""${path.module}/default_components/linux/amazon_2023/"
                ### otherwise we support override of all component object keys
                "100_install_dod_certs"   = { path    = "install_dod_certs.yml" }
                "200_configure_git"       = { path    = "configure_git.yml", parameters = {} }
                "300_oscap_scan"          = { path    = "oscap_scan.yml" ,parameters = { audit_bucket_name = local.audit_bucket_name}}
        }

        default_components_aws = {
                "100_install_dod_certs"   = { path    = "install_dod_certs.yml" }
                "200_enable_fips"         = { path    = "enable_fips.yml" }
                "300_setup_partitions"    = { path    = "setup_partitions.yml" }
                "400_aws_al2023_stig"     = { name = "aws:component/stig-build-linux/x.x.x",  parameters    = { Level = "High" } }
                "500_oscap_scan"          = { path    = "oscap_scan.yml", parameters = { audit_bucket_name = local.audit_bucket_name } }
        }

        default_components_awsdebug = {
                "100_install_dod_certs"   = { path    = "install_dod_certs.yml" }
                "200_enable_fips"         = { path    = "enable_fips.yml" }
                "300_setup_partitions"    = { path    = "setup_partitions.yml" }
                "400_aws_al2023_stig"     = { name = "aws:component/stig-build-linux/x.x.x", parameters    = { Level= "High" } }
                "500_oscap_scan"          = { path    = "oscap_scan.yml", parameters = { audit_bucket_name = local.audit_bucket_name } }
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
  # Component key => AWS resource name.
  component_names = {
    for c, a in local.merged_components_list :
    c => lower(replace("${var.globals["aws_resource_nametag_prefix"]}_${var.image_name}_${substr(c, 4, -1)}", "_", "-"))
    if !local.is_managed[c]
  }

  # Component key => YAML path. included_components_config_path already has path.module.
  component_files = {
    for c, a in local.merged_components_list :
    c => "${local.included_components_config_path}/${a.path != "" ? a.path : "${substr(c, 4, -1)}.yml"}"
    if !local.is_managed[c]
  }

  # Rendered once so the hash covers exactly what gets uploaded.
  component_docs = {
    for c, f in local.component_files :
    c => length(local.merged_components_list[c].parameters) > 0 ? templatefile(f, local.merged_components_list[c].parameters) : file(f)
  }

  component_hashes = { for c, doc in local.component_docs : c => md5(doc) }

  # Caller owns major.minor. We manage the patch number.
  version_lines = {
    for c, a in local.merged_components_list :
    c => length(regexall("^\\d+\\.\\d+\\.\\d+$", a.version)) > 0 ? "${split(".", a.version)[0]}.${split(".", a.version)[1]}" : "1.0"
    if !local.is_managed[c]
  }
}

locals {
  # ARN: arn:...:component/<name>/<major>.<minor>.<patch>/<build>
  published_builds = [
    for arn in data.aws_imagebuilder_components.historical_versions.arns : {
      arn   = arn
      name  = split("/", arn)[1]
      line  = "${split(".", split("/", arn)[2])[0]}.${split(".", split("/", arn)[2])[1]}"
      patch = tonumber(split(".", split("/", arn)[2])[2])
      build = tonumber(split("/", arn)[3])
    }
    if length(split("/", arn)) == 4
  ]

  # Newest build per component as "patch|build|arn", or "" if never published.
  # Zero-padded so a text sort orders numerically.
  newest_build = {
    for c, line in local.version_lines :
    c => try(reverse(sort([
      for b in local.published_builds : format("%09d|%09d|%s", b.patch, b.build, b.arn)
      if b.name == local.component_names[c] && b.line == line
    ]))[0], "")
  }

  published_patch = { for c, s in local.newest_build : c => s == "" ? -1 : tonumber(split("|", s)[0]) }
  published_arn   = { for c, s in local.newest_build : c => s == "" ? "" : split("|", s)[2] }
}

data "aws_imagebuilder_component" "published" {
  for_each = { for c, arn in local.published_arn : c => arn if arn != "" }

  arn = each.value
}

locals {
  # Compare the tag we set at publish time, not the document body, which AWS may reformat.
  content_changed = {
    for c, arn in local.published_arn :
    c => arn == "" || try(data.aws_imagebuilder_component.published[c].tags["content_md5"], "") != local.component_hashes[c]
  }

  # Unchanged: hold. Changed or new: next patch. Never published is patch -1, so new starts at .0.
  component_versions = {
    for c, line in local.version_lines :
    c => local.content_changed[c] ? "${line}.${local.published_patch[c] + 1}" : "${line}.${local.published_patch[c]}"
  }
}

output "component_versions" {
  value = local.component_versions
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
                                                                                                     : "arn:aws-us-gov:imagebuilder:${var.globals["region"]}:${var.globals["account_id"]}:component/${local.component_names[component]}/${local.component_versions[component]}" )
                                                                                                                                        
                                                                path               = local.is_managed[component] ? "" : local.component_files[component]

                                                                version            = local.is_managed[component] ? "" : local.component_versions[component]

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


locals {
  recipe_name = "${var.globals["aws_resource_nametag_prefix"]}_${var.image_name}"

  # A recipe version is immutable, so any change here needs a new version.
  # block_device_mapping is excluded because the resource ignores changes to it.
  # nonsensitive: parent_image comes from SSM, which marks every value sensitive.
  recipe_payload = {
    parent_image = nonsensitive(local.recipe_parent_image)
    components = [
      for c in sort(keys(local.prepared_components_list)) : {
        arn        = local.prepared_components_list[c].arn
        parameters = local.prepared_components_list[c].parameters
      }
    ]
  }

  recipe_hash = md5(jsonencode(local.recipe_payload))

  recipe_line = length(regexall("^\\d+\\.\\d+\\.\\d+$", var.recipe_version)) > 0 ? "${split(".", var.recipe_version)[0]}.${split(".", var.recipe_version)[1]}" : "1.0"
}

data "aws_imagebuilder_image_recipes" "historical_versions" {
  owner = "Self"
}

locals {
  # ARN: arn:...:image-recipe/<name>/<major>.<minor>.<patch>. No build node.
  published_recipes = [
    for arn in data.aws_imagebuilder_image_recipes.historical_versions.arns : {
      arn   = arn
      name  = split("/", arn)[1]
      line  = "${split(".", split("/", arn)[2])[0]}.${split(".", split("/", arn)[2])[1]}"
      patch = tonumber(split(".", split("/", arn)[2])[2])
    }
    if length(split("/", arn)) == 3
  ]

  # Newest recipe as "patch|arn", or "" if never published.
  newest_recipe = try(reverse(sort([
    for r in local.published_recipes : format("%09d|%s", r.patch, r.arn)
    if r.name == local.recipe_name && r.line == local.recipe_line
  ]))[0], "")

  published_recipe_patch = local.newest_recipe == "" ? -1 : tonumber(split("|", local.newest_recipe)[0])
  published_recipe_arn   = local.newest_recipe == "" ? "" : split("|", local.newest_recipe)[1]
}

data "aws_imagebuilder_image_recipe" "published" {
  count = local.published_recipe_arn == "" ? 0 : 1

  arn = local.published_recipe_arn
}

locals {
  recipe_changed = local.published_recipe_arn == "" || try(data.aws_imagebuilder_image_recipe.published[0].tags["content_md5"], "") != local.recipe_hash

  # var.recipe_version supplies major.minor. The patch is managed here.
  recipe_version = local.recipe_changed ? "${local.recipe_line}.${local.published_recipe_patch + 1}" : "${local.recipe_line}.${local.published_recipe_patch}"
}

output "recipe_version" {
  value = local.recipe_version
}
