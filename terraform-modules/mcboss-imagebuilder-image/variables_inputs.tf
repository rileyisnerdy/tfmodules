#####################################################################################################################################################
### REQUIRED INPUTS:
#####################################################################################################################################################
variable "globals" {
        description = "(Required) Map of environment specific values uniformally leveraged in this module."
        #type = map(string)
}

variable "image_name" {
        description = "(Required) String base Name for the Image Builder resources"
        type        = string
        ### FIXME: Validate block for this?
}

variable "eks_version" {
        description = "(Required) String of EKS Kubernetes minor version (e.g., '1.30', '1.35')"
        type        = string
        ### FIXME: Validate block for this?
}


variable "recipe_parent_image_archetype" {
        description = "(Required;Optional) String, Image Archetype for ImageBuilder host ( AL2023 | RHEL9 ) Exclusive with recipe_parent_image "
        type = string
        default = ""
}

variable "recipe_parent_image" {
        description = "(Required;Optional) String, Image AMI ID. Exclusive with recipe_parent_image_archetype"
        type = string
        default = ""
}

variable "recipe_version" {
        description = "(Required) String, Semantic Version of the image recipe itself x.y.z"
        ### https://docs.aws.amazon.com/imagebuilder/latest/APIReference/API_CreateComponent.html#API_CreateComponent_RequestSyntax
        ### NOTE:
        ###     The semantic version has four nodes: <major>.<minor>.<patch>/<build>. 
        ###     You can assign values for the first three, and can filter on all of them.
        ###
        ### ASSIGNMENT: 
        ###     For the first three nodes you can assign 
        ###             any positive integer value, including zero, 
        ###             with an upper limit of 2^30-1, or 1073741823 for each node.
        ###     Image Builder automatically assigns the build number to the fourth node.
        ###
        ### PATTERNS:
        ###     Requires: ^[0-9]+\.[0-9]+\.[0-9]+$
        ###     You can use any numeric pattern that adheres to the assignment requirements for the nodes that you can assign. 
        ###     For example, you might choose either:
        ###              a software version pattern, such as '1.0.0'
        ###              or a date, such as '2021.01.01'
        type        = string
        ### FIXME: Validate block for this?
}

variable "components_config_path" {
        description = "(Required) String, path.root relative path to image configuration assets"
        type = string
}

variable "components_map" {
        description = "(Required) Rich Value Type List of components. Order determines execution sequence."
        default = {}
}

variable "default_component_set" {
        description = "(Optional) Cannot be used with components_map and or components_config_path, can only be one of: 'cis', 'aws', 'awsdebug'"
        type = string
        default = ""
}



#####################################################################################################################################################
### OPTIONAL INPUTS:
#####################################################################################################################################################
variable "recipe_parent_image_id" {
        description = "(Optional) String, AWS AMI ID for ImageBuilder host"
        type = string
        default = ""
}

variable "block_device_mappings" {
  description = "(Optional) Rich Value Type List of EBS block devices to attach to the image recipe"
  type = list(object({
    device_name           = string
    delete_on_termination = bool
    volume_size           = number
    volume_type           = string
  }))
  default = [
    {
      device_name           = "/dev/xvda"
      delete_on_termination = true
      volume_size           = 100
      volume_type           = "gp3"
    }
  ]
}

variable "terminate_instance_on_failure" {
  type        = bool
  description = "(Optional) Bool, if false, the EC2 build instance remains running for debugging if the pipeline fails or finishes"
  default     = true
}

variable "additional_security_group_ids" {
  type        = list(string)
  description = "(Optional) List of strings of Security Group IDs for the build instance"
  default     = []
}

#####################################################################################################################################################
### OPTIONAL INPUTS: ONDEMAND
#####################################################################################################################################################
variable "ondemand_pipeline_status" {
        type        = string
        description = "(Optional) String Status of the ondemand pipeline (ENABLED or DISABLED)"
        default     = "ENABLED"
}
variable "ondemand_pipeline_create_toggle" {
        type = bool
        description = "(Optional) Bool true false toggle enabling of the ondemand pipeline"
        default = false
}

variable "ondemand_pipeline_tests_toggle" {
        type = bool
        description = "(Optional) Bool value true or false"
        default = false
}

variable "ondemand_pipeline_tests_timeout" {
        type = number
        description = "(Optional) Number value in mins"
        default = 720
}






#####################################################################################################################################################
### OPTIONAL INPUTS: CRON
#####################################################################################################################################################
variable "cron_pipeline_create_toggle" {
        type = bool
        description = "(Optional) Bool true false toggle enabling of the cron pipeline"
        default = false
}
variable "cron_pipeline_schedule_expression" {
        type        = string
        description = "(Optional) String Cron expression for the pipeline schedule (e.g., 'cron(0 0 * * ? *)'). Leave empty for manual triggers."
        default     = "" # "cron(0 9 ? * mon)"
}

variable "cron_pipeline_execute_condition" {
        type        = string
        description = "(Optional) String Execution Condition of the cron pipeline (EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE or EXPRESSION_MATCH_ONLY)"
        default     = "EXPRESSION_MATCH_ONLY"
        # EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE
        # EXPRESSION_MATCH_ONLY
        # MATCH 
        # MATCH_AND_DEPENDENCY
        # CRON 
        # CRON_AND_DEPENDENCY
        # CRON_ONLY
        # CRON_AND_DEPENDENCY
                                                          ### EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE means:
                                                          ###        Will attempt to run on the scheduled cron cadence
                                                          ###        AND, only IF AWS has released a new parent EKS image
                                                          ###         OR our components have been updated.
                                                          ###
                                                          ### EXPRESSION_MATCH_ONLY means:
                                                          ###        Will attempt to run on the scheduled cron cadence
}

variable "cron_pipeline_tests_toggle" {
        type = bool
        description = "(Optional) Bool value true or false"
        default = false
}

variable "cron_pipeline_tests_timeout" {
        type = number
        description = "(Optional) Number value in mins"
        default = 720
}

variable "cron_pipeline_status" {
        type        = string
        description = "(Optional) String Status of the cron pipeline (ENABLED or DISABLED)"
        default     = "ENABLED"
}