resource "aws_iam_policy" "imagebuilder_s3audit_permissions" {
        name   = "${var.globals["aws_resource_nametag_prefix"]}_imagebuilder_${var.image_name}_s3audit_permissions"
        policy = data.aws_iam_policy_document.imagebuilder_s3audit_permissions.json
}

resource "aws_iam_role_policy_attachment" "imagebuilder_s3audit_permissions" {
        role       = aws_iam_role.this.name
        policy_arn = aws_iam_policy.imagebuilder_s3audit_permissions.arn
}

data "aws_iam_policy_document" "imagebuilder_s3audit_permissions" {
        statement {
                sid        = "AllowEC2RoleSSMAccess"
                effect     = "Allow"
                actions    = [ "ssm:GetParameter" ]
                resources = [ "*" ] ### FIXME: Restrict this to the specific parameter ARN in production if desired
        }

        statement {
                sid        = "AllowEC2RoleObjectAccess"
                effect     = "Allow"
                actions    = [ "s3:PutObject",
                               "s3:GetObjectVersion"
                ]
                resources = [ "${aws_s3_bucket.audit.arn}/*" ]
        }

        statement {
                sid        = "AllowEC2RoleBucketAccess"
                effect     = "Allow"
                actions    = [ "s3:ListBucket",
                               "s3:GetBucketLocation"
                ]
                resources = [ aws_s3_bucket.audit.arn ]
        }
}
