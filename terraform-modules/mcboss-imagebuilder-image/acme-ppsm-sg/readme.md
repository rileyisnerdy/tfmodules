# acme PPSM Security Groups

Terraform module for managing AWS Security Groups and their respective rules from a PPSM document. Template PPSM document is provided in `ppsm_example/ppsm_example_sg_rules.csv`

## Overview

This project automates the creation and configuration of AWS Security Groups using information from a PPSM CSV document:

1. Define rules in PPSM CSV.
2. Rules are validated by the `input_validation` module
3. Terraform creates security groups and ingress/egress rules

## Example Default Usage

```
module "sg" {
    source = "git::ssh://git@git.acme.usmc.mil/terraform-modules/acme-ppsm-sg.git?ref=v1.0.0""
    vpc_id = local.vpc_id
    aws_resource_nametag_prefix = local.aws_resource_nametag_prefix
    rules_path  = "/ppsm/sg_rules.csv"
  
}


```

## Example With Globals Input

If you build a map like so inside your root module and pass it into the child module you can reference the values by map keys inside your ppsm csv file

```
locals {
    globals = {
        account_vpc_cidr = var.account_vpc_cidr
    }
}
```

```
module "sg" {
    source = "git::ssh://git@git.acme.usmc.mil/terraform-modules/acme-ppsm-sg.git?ref=v1.0.0""
    vpc_id = local.vpc_id
    aws_resource_nametag_prefix = local.aws_resource_nametag_prefix
    rules_path  = "/ppsm/sg_rules.csv"
    globals = local.globals
  
}


```




## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `vpc_id` | VPC ID where security groups will be created | `string` | Yes |
| `rules_path` | Path where PPSM CSV file exists | `string` | Yes |
| `aws_resource_nametag_prefix` | The prefix used for naming AWS resources. Derived from environment_shorthand and account_application (e.g. dev_rdais) | `string` | Yes |
| `globals` | Map of environment specific cidr values | `string` | No |

## Outputs

| Name | Description |
|------|-------------|
| `security_groups` | Map of all created security group objects |

## CSV Rule Format

Rules are defined in with the following columns:

| Column | Description | Example |
|--------|-------------|---------|
| `rule_id` | Unique identifier for the rule | `ad_out_tcp_443_vpc_endpoints` |
| `sg_name` | Security group name | `ad_sg` |
| `type` | Rule direction | `ingress` or `egress` |
| `protocol` | IP protocol | `tcp`, `udp`, or `all` |
| `from_port` | Start port (empty for all traffic) | `443` |
| `to_port` | End port (empty for all traffic) | `443` |
| `cidr_ipv4` | IPv4 CIDR block | `10.0.4.196/32` |
| `cidr_ipv6` | IPv6 CIDR block | `2001:0db8:85a3::/128` |
| `source_sg_name` | Source security group name | `jenkins_sg` |
| `prefix_list_id` | AWS prefix list ID | `pl-09facf55a643b3a65` |
| `description` | Rule description | `HTTPS(tcp/443) from Bastion Zone 1 to NIPRNet ` |

**Note:** Each rule must have exactly ONE source: `cidr_ipv4`, `cidr_ipv6`, `source_sg_name`, OR `prefix_list_id`.

## Rule ID Format

Rule IDs follow the pattern: `{sg_short}_{direction}_{protocol}_{port(s)}_{shortened_description}` All rule ids MUST be unique.

| Component | Values | Example |
|-----------|--------|---------|
| `sg_short` | Shortened SG name (without `_sg` suffix) | `ad`, `bastion`, `jenkins` |
| `direction` | `in` (ingress) or `out` (egress) | `in`, `out` |
| `protocol` | `tcp`, `udp`, or `all` (for -1) | `tcp` |
| `port(s)` | Single port or `from_to` range | `443`, `49152_65535` |
| `shortened description` | Brief rule description outlying what the egress or ingress is | `vpc_endpoints` |

Example: `ad_out_tcp_443_vpc_endpoints`  This rule id shows that its the `ad` security group, the direction is `out` (egress), the protocol is `tcp`, the port is `443`, and the brief description at the end identifies the destination are the vpc endpoints.

## Validation

The module enforces the following validation:

- Each rule has exactly one source (CIDR, SG reference, or prefix list)
- Valid CIDR notation for IPv4/IPv6 blocks
- Security group names are 1-255 characters
- Security group names don't start with `sg-` (AWS reserved)
- Security group names contain only valid characters
- Prefix list IDs match AWS format (`pl-` followed by 8-17 hex characters)


## Requirements
| Name | Version |
|------|---------|
|`terraform` | >=0.14.11
|`aws` | >= 5.65.0
