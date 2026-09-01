locals {
        acme_provided = { ### FIXME: This is now a nested locals value to be referenced with ["key"] below
                account_alias                                      =  data.terraform_remote_state.acme_iac_backend.outputs.account_alias
                account_application                                =  data.terraform_remote_state.acme_iac_backend.outputs.account_application
                account_cidr                                       =  data.terraform_remote_state.acme_iac_backend.outputs.account_cidr
                cidr_scope                                         =  data.terraform_remote_state.acme_iac_backend.outputs.cidr_scope
                account_environment                                =  data.terraform_remote_state.acme_iac_backend.outputs.account_environment
                account_id	                                   =  data.terraform_remote_state.acme_iac_backend.outputs.account_id
                application_shorthand                              =  data.terraform_remote_state.acme_iac_backend.outputs.application_shorthand
                availability_zone1                                 =  data.terraform_remote_state.acme_iac_backend.outputs.availability_zone1
                availability_zone2                                 =  data.terraform_remote_state.acme_iac_backend.outputs.availability_zone2
                availability_zone3                                 =  data.terraform_remote_state.acme_iac_backend.outputs.availability_zone3
                aws_default_tags                                   =  data.terraform_remote_state.acme_iac_backend.outputs.aws_default_tags
                aws_resource_nametag_prefix	                   =  data.terraform_remote_state.acme_iac_backend.outputs.aws_resource_nametag_prefix
                cloudwatch_destination_account_id                  =  data.terraform_remote_state.acme_iac_backend.outputs.cloudwatch_destination_account_id
                environment_shorthand                              =  data.terraform_remote_state.acme_iac_backend.outputs.environment_shorthand
                integration_with_acme_scca_sg_id                 =  data.terraform_remote_state.acme_iac_backend.outputs.integration_with_acme_scca_sg_id
                acme_scca_domain_name                            =  data.terraform_remote_state.acme_iac_backend.outputs.acme_scca_domain_name
                acme_vdms_activedirectory_zone1_ip               =  data.terraform_remote_state.acme_iac_backend.outputs.acme_vdms_activedirectory_zone1_ip
                acme_vdms_activedirectory_zone2_ip               =  data.terraform_remote_state.acme_iac_backend.outputs.acme_vdms_activedirectory_zone2_ip
                acme_vdss_f5_bgp_zone1_cidr                      =  data.terraform_remote_state.acme_iac_backend.outputs.acme_vdss_f5_bgp_zone1_cidr
                acme_vdss_f5_bgp_zone2_cidr                      =  data.terraform_remote_state.acme_iac_backend.outputs.acme_vdss_f5_bgp_zone2_cidr
                acme_vdss_f5_bgp_zone1_ip                        =  data.terraform_remote_state.acme_iac_backend.outputs.acme_vdss_f5_bgp_zone1_ip
                acme_vdss_f5_bgp_zone2_ip                        =  data.terraform_remote_state.acme_iac_backend.outputs.acme_vdss_f5_bgp_zone2_ip
                acme_vdss_account_id                             =  data.terraform_remote_state.acme_iac_backend.outputs.acme_vdss_account_id
                acme_vdss_vpc_id                                 =  data.terraform_remote_state.acme_iac_backend.outputs.acme_vdss_vpc_id
                region                                             =  data.terraform_remote_state.acme_iac_backend.outputs.region
                vpc_endpoint_interfaces_sg_id                      =  data.terraform_remote_state.acme_iac_backend.outputs.vpc_endpoint_interfaces_sg_id
                vpc_id                                             =  data.terraform_remote_state.acme_iac_backend.outputs.vpc_id
                vpc_route53_resolver_ip                            =  data.terraform_remote_state.acme_iac_backend.outputs.vpc_route53_resolver_ip
                vpc_subnet_services_zone1_id                       =  data.terraform_remote_state.acme_iac_backend.outputs.vpc_subnet_services_zone1_id
                vpc_subnet_services_zone2_id                       =  data.terraform_remote_state.acme_iac_backend.outputs.vpc_subnet_services_zone2_id
                #vpc_subnet_services_zone3_id                       =  local.acme_provided["cidr_scope"] ==  "24" ? null : try(data.terraform_remote_state.acme_iac_backend.outputs.vpc_subnet_services_zone3_id, "")
                vpc_subnet_workloads_zone1_id                      =  data.terraform_remote_state.acme_iac_backend.outputs.vpc_subnet_workloads_zone1_id
                vpc_subnet_workloads_zone2_id                      =  data.terraform_remote_state.acme_iac_backend.outputs.vpc_subnet_workloads_zone2_id
                #vpc_subnet_workloads_zone3_id                      =  local.acme_provided["cidr_scope"] ==  "24" ? null : try(data.terraform_remote_state.acme_iac_backend.outputs.vpc_subnet_services_zone3_id, "")
                vpc_subnet_services_zone1_cidr                     =  data.terraform_remote_state.acme_iac_backend.outputs.vpc_subnet_services_zone1_cidr
                vpc_subnet_services_zone2_cidr                     =  data.terraform_remote_state.acme_iac_backend.outputs.vpc_subnet_services_zone2_cidr
                #vpc_subnet_services_zone3_cidr                     =  local.acme_provided["cidr_scope"] ==  "24" ? null : try(data.terraform_remote_state.acme_iac_backend.outputs.vpc_subnet_services_zone3_id, "")
                vpc_subnet_workloads_zone1_cidr                    =  data.terraform_remote_state.acme_iac_backend.outputs.vpc_subnet_workloads_zone1_cidr
                vpc_subnet_workloads_zone2_cidr                    =  data.terraform_remote_state.acme_iac_backend.outputs.vpc_subnet_workloads_zone2_cidr
                #vpc_subnet_workloads_zone3_cidr                    =  local.acme_provided["cidr_scope"] ==  "24" ? null : try(data.terraform_remote_state.acme_iac_backend.outputs.vpc_subnet_services_zone3_id, "")
                aws_iam_policy_ec2_cloudwatch_logstreams_allow_arn =  data.terraform_remote_state.acme_iac_backend.outputs.aws_iam_policy_ec2_cloudwatch_logstreams_allow_arn
        }
}