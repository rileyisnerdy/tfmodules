resource "aws_iam_role" "this" {
        name  = "${var.globals["aws_resource_nametag_prefix"]}_imagebuilder_${var.image_name}"
        assume_role_policy = data.aws_iam_policy_document.this_assume_role.json
}

data "aws_iam_policy_document" "this_assume_role" {
        statement {
                effect    = "Allow"
                actions   = ["sts:AssumeRole"]
                principals {
                        type        = "Service"
                        identifiers = [ "ec2.amazonaws.com",
                                        "imagebuilder.amazonaws.com",
                                        "ssm.amazonaws.com",
                                        "vpc-flow-logs.amazonaws.com"
                                      ]
                }

        }
}


resource "aws_iam_instance_profile" "this" {
  name  = "${var.globals["aws_resource_nametag_prefix"]}_imagebuilder_${var.image_name}_profile"
  role  = aws_iam_role.this.name
}

