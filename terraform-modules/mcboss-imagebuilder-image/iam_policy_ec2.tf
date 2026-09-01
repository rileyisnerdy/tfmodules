resource "aws_iam_policy" "imagebuilder_ec2profile_permissions" {
        name   = "${var.globals["aws_resource_nametag_prefix"]}_imagebuilder_${var.image_name}_ec2profile_permissions"
        policy = data.aws_iam_policy_document.imagebuilder_ec2profile_permissions.json
}

resource "aws_iam_role_policy_attachment" "imagebuilder_ec2profile_permissions" {
        role       = aws_iam_role.this.name
        policy_arn = aws_iam_policy.imagebuilder_ec2profile_permissions.arn
}

### Based on the AWS provided: "EC2InstanceProfileForImageBuilder"
data "aws_iam_policy_document" "imagebuilder_ec2profile_permissions" {
        statement {
                effect = "Allow"
                actions = [ "imagebuilder:GetComponent" ]
                resources = ["*"]
                ### the following conditions do NOT exist in AWS provided policy
                #condition {
                #        test     = "ForAnyValue:StringEquals"
                #        variable = "kms:EncryptionContextKeys"
                #        values   = ["aws:imagebuilder:arn"]
                #}

                #condition {
                #        test     = "ForAnyValue:StringEquals"
                #        variable = "aws:CalledVia"
                #        values   = ["imagebuilder.amazonaws.com"]
                #}
        }

        statement {
                sid = "AllowKMSUse"
                effect = "Allow"
                actions = [ #"kms:CreateGrant",
                            #"kms:DescribeKey",
                            #"kms:GenerateDataKeyWithoutPlainText",
                            #"kms:ReEncrypt",
                            "kms:Decrypt"
                ]
                resources = ["*"]
                condition {
                        test     = "ForAnyValue:StringEquals"
                        variable = "kms:EncryptionContextKeys"
                        values   = ["aws:imagebuilder:arn"]
                }
                condition {
                        test     = "ForAnyValue:StringEquals"
                        variable = "aws:CalledVia"
                        values   = ["imagebuilder.amazonaws.com"]
                }
        }

        statement {
                effect = "Allow"
                actions = ["s3:GetObject" ]
                resources = ["arn:aws-us-gov:s3:::ec2imagebuilder*"]
        }

        statement {
                effect = "Allow"
                actions = ["logs:CreateLogStream",
                           "logs:CreateLogGroup",
                           "logs:PutLogEvents"
                ]
                resources = ["arn:aws-us-gov:logs:${var.globals["region"]}:${var.globals["account_id"]}:log-group:/aws/imagebuilder/*"]
        }
}
