variable "rules" {
  description = "Raw security group rules in CSV format"
  type = list(object({
    rule_id        = string
    sg_name        = string
    type           = string
    protocol       = string
    from_port      = string
    to_port        = string
    source_sg_name = string
    description    = string
    prefix_list_id = string
    cidr_ipv4      = string
    cidr_ipv6      = string
  }))

### Unique rule reference for IPs/SGs/PLs
  validation {
    error_message = "Each rule can only have ONE source: cidr_ipv4, cidr_ipv6, source_sg_name, OR prefix_list_id. Check rules with multiple sources set."
    condition = alltrue([
      for r in var.rules : length([for src in [trimspace(r.cidr_ipv4),
                                               trimspace(r.cidr_ipv6), 
                                               trimspace(r.source_sg_name), 
                                               trimspace(r.prefix_list_id)
                                               ] : src if src != ""]) == 1
      
    ])
  }

### SG and Source SG Name length 
  validation {
    error_message = "Security Group names must be between 1 and 255 characters."
    condition = alltrue([
      for r in var.rules : (
        (length(trimspace(r.sg_name)) > 0 && length(trimspace(r.sg_name)) <= 255) &&
        (trimspace(r.source_sg_name) == "" || (length(trimspace(r.source_sg_name)) > 0 && length(trimspace(r.source_sg_name)) <= 255))
      )
    ])
  }
### SG and Source SG !startswith(sg-)
  validation {
    error_message = "Security Group names cannot start with 'sg-'."
    condition = alltrue([
      for r in var.rules : (
        (length(regexall("^sg-", trimspace(r.sg_name))) == 0) &&
        (trimspace(r.source_sg_name) == "" || length(regexall("^sg-", trimspace(r.source_sg_name))) == 0)
      )
    ])
  }

    validation {
    error_message = "Security Group names can only contain: a-z, A-Z, 0-9, spaces, and ._-:/()#,@[]+=&;{}!$*  ."
    condition = alltrue([
      for r in var.rules :  (length(regexall("^[a-zA-Z0-9 ._\\-:/()#,@\\[\\]+=&;{}!$*]+$", trimspace(r.sg_name))) > 0) &&
                            (trimspace(r.source_sg_name) == "" || (length(regexall("^[a-zA-Z0-9 ._\\-:/()#,@\\[\\]+=&;{}!$*]+$", trimspace(r.source_sg_name))) > 0))

                           
    ])
  }

### PL ID character contents
 validation {
    error_message = "Prefix List IDs can only contain: ^pl-[0-9a-f]{8,17}$  ."
    condition =  alltrue([
      for r in var.rules : trimspace(r.prefix_list_id) == "" ||
                           length([regexall("^pl-[0-9a-f]{8,17}$", trimspace(r.prefix_list_id))]) > 0
                          
                                        
      
    ])
  }
  
}




output "rules" {
    value = var.rules
}