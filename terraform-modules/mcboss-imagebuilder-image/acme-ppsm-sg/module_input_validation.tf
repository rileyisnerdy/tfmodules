module "validation_of_rules" {
    source = "./input_validation"
    #rules = csvdecode(file("${path.root}/${var.rules_path}")) 
    rules = csvdecode( (var.rules_file != "") ? (var.rules_file) : (file("${path.module}/${var.rules_path}"))) 
}

variable "rules_path" {
    default = ""
    type = string
}

variable "rules_file" {
    default = ""
    type = string
}