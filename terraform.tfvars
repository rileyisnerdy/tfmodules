##DEBUG IMAGE BUILDER PIPELINE##
imagebuilder_eks_debug_eks_version = "1.35"
imagebuilder_eks_debug_image_name = "eks_debug"
imagebuilder_eks_debug_recipe_parent_image_archetype = "AL2023"
imagebuilder_eks_debug_recipe_version = "1.0.4"

#imagebuilder_eks_debug_components_config_path  = "./default_components/linux/amazon_2023"
#imagebuilder_eks_debug_components_map = {
#        "all_default_component_values"            = {}
#        "override_custom_component_values"        = { path = "tfroot/level/path/to/example_component.yml", name = "the-best-component", version = "7.7.7"}
#        "parameterized_custom_component_values"   = { parameters = [{ name = "Key", value = "Value" }]}
#
#
#        "aws:component/stig-build-linux/x.x.x" = { parameters    = [{ name = "Level", value = "High" }] }
#}

imagebuilder_eks_debug_components_config_path  = "default_components/linux/amazon_2023"
imagebuilder_eks_debug_components_map = {
                "100_install_dod_certs"   = {}
                "200_enable_fips"         = {}
                "300_setup_partitions"    = {}
                "400_aws_al2023_stig"     = { name = "aws:component/stig-build-linux/x.x.x", parameters    = [{ name = "Level", value = "High" }] }
                "500_oscap_scan"          = { parameters = [{ name = "audit_bucket_name", value = "dev-mbct-imagebuilder-eks-debug-audit"}]}
                "600_force_failure"       = {}
}

imagebuilder_eks_debug_block_device_mappings = [
        {
                "device_name"          = "/dev/xvda"
                "delete_on_termination" = true
                "volume_size"           = 100
                "volume_type"           = "gp3"
        },
        {
                "device_name"           = "/dev/sdb"
                "delete_on_termination" = true
                "volume_size"           = 150 
                "volume_type"           = "gp3"
        }
]


##STIG BUILD LINUX IMAGE BUILDER PIPELINE##
imagebuilder_eks_stig_build_linux_eks_version = "1.35"
imagebuilder_eks_stig_build_linux_image_name = "eks_stig_build_linux"
imagebuilder_eks_stig_build_linux_recipe_parent_image_archetype = "AL2023"
imagebuilder_eks_stig_build_linux_recipe_version = "1.0.4"

imagebuilder_eks_stig_build_linux_components_config_path  = "default_components/linux/amazon_2023"
imagebuilder_eks_stig_build_linux_components_map = {
                "100_install_dod_certs"   = {}
                "200_enable_fips"         = {}
                "300_setup_partitions"    = {}
                "400_aws_al2023_stig"     = { name = "aws:component/stig-build-linux/x.x.x", parameters    = [{ name = "Level", value = "High" }] }
                "500_oscap_scan"          = { parameters = [{ name = "audit_bucket_name", value = "dev-mbct-imagebuilder-eks-stig-build-linux-audit"}]}
}

imagebuilder_eks_stig_build_linux_block_device_mappings = [
        {
                "device_name"          = "/dev/xvda"
                "delete_on_termination" = true
                "volume_size"           = 100
                "volume_type"           = "gp3"
        },
        {
                "device_name"           = "/dev/sdb"
                "delete_on_termination" = true
                "volume_size"           = 150 
                "volume_type"           = "gp3"
        }
]