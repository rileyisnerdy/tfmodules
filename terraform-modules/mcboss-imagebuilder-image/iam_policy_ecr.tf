resource "aws_iam_policy" "imagebuilder_ecr_permissions" {
        name   = "${var.globals["aws_resource_nametag_prefix"]}_imagebuilder_${var.image_name}_ecr_permissions"
        policy = data.aws_iam_policy_document.imagebuilder_ecr_permissions.json
}

resource "aws_iam_role_policy_attachment" "imagebuilder_ecr_permissions" {
        role       = aws_iam_role.this.name
        policy_arn = aws_iam_policy.imagebuilder_ecr_permissions.arn
}

data "aws_iam_policy_document" "imagebuilder_ecr_permissions" {
        statement {
                sid        = "AllowEC2RoleECRAccess"
                effect     = "Allow"
                actions    = [ "ecr:GetDownloadUrlForLayer",
                               "ecr:BatchGetImage",
                               "ecr:BatchCheckLayerAvailability"
                ]
                resources = ["arn:aws-us-gov:ecr:${var.globals["region"]}:${var.globals["account_id"]}:repository/*"]
        }
        
        statement {
                sid        = "AllowEC2RoleECRTokenAccess"
                effect     = "Allow"
                actions    = [ "ecr:GetAuthorizationToken" ]
                resources  = [ "*" ]
        }
}
