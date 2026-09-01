### Terraform Core & Providers
###
### as of v0.13.0 , 'terraform' block expanded to contain 'required_providers' and child-objects. 
###                     Modern syntax explained:  https://developer.hashicorp.com/terraform/language/providers/requirements
###
###       v0.12.x , refer to the legacy 'terraform'/'providers' block requirements.
###                     legacy syntax explained: https://developer.hashicorp.com/terraform/language/providers/requirements#v0-12-compatible-provider-requirements
###
###
###        ALL versions should be pinned (equal to exactly what is being used)
###                     External deps are decoupled using local mirror directories, ".terraformrc"/".terraform.tfrc"
###                     https://developer.hashicorp.com/terraform/cli/config/config-file#implied-local-mirror-directories
###
###        ALL 'terraform' blocks still do not support interpolation for values within them.
###
terraform {
        required_version = "= 0.14.11" ## Terraform Core Version
        #backend "s3" { }
        required_providers {
                aws = { ## aka "hashicorp/aws"
                        source  = "registry.terraform.io/hashicorp/aws" 
                        version = "5.95.0"
                }
        }
}
###        ALL 'provider' blocks DO support some direct-input variables.
###                     You can use expressions in the values of these configuration arguments, but can only reference 
###                     values that are known before the configuration is applied. This means you can safely reference input variables, 
###                     but not attributes exported by resources (with an exception for resource arguments that are specified directly in the configuration).
###                     NOTE!       the part about "The body of the block, between '{' and '}'    ::     https://developer.hashicorp.com/terraform/language/providers/configuration
###                     NOTE!       built-in "expresssions" mentioned above     ::        https://developer.hashicorp.com/terraform/language/expressions
provider "aws" {
    region = "us-gov-west-1"
    default_tags {
        tags = data.terraform_remote_state.mcboss_iac_backend.outputs.aws_default_tags
    }
}

### How to test and leverage local-remote states
data "terraform_remote_state" "mcboss_iac_backend" {
        backend = "local"

        config = {
                path = "./usmc_mbct_development_backend.terraform.tfstate"
        }
}

