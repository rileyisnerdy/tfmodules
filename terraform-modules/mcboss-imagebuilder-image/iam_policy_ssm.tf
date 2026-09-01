resource "aws_iam_policy" "image_builder_ssm" {
        name   = "${var.globals["aws_resource_nametag_prefix"]}_imagebuilder_${var.image_name}_ssm_permissions"
  policy = data.aws_iam_policy_document.image_builder_ssm_policy.json
}

resource "aws_iam_role_policy_attachment" "image_builder_ssm" {
        role       = aws_iam_role.this.name
        policy_arn = aws_iam_policy.image_builder_ssm.arn
}


data "aws_iam_policy_document" "image_builder_ssm_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:ListInstanceAssociations",
      "ssm:PutComplianceItems",
      "ssm:PutConfigurePackageResult",
      "ssm:PutInventory",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:DescribeDocument",
      "ssm:GetDocument",
      "ssm:GetManifest"
    ]
    resources = [
      "arn:aws-us-gov:ssm:${var.globals["region"]}:${var.globals["account_id"]}:document/AmazonInspector2-InspectorSsmPluginLinux",
      "arn:aws-us-gov:ssm:${var.globals["region"]}:${var.globals["account_id"]}:document/AWS-GatherSoftwareInventory"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
        "ssm:GetParameter",
        "ssm:GetParameters"
    ]
     resources = [
      "arn:aws-us-gov:ssm:${var.globals["region"]}:${var.globals["account_id"]}:parameter/imagebuilder/gitlab/*"
     ]
  }

  #statement {
  #  effect = "Allow"
  #  actions = [
  #      "kms:Decrypt",
  #      "kms:DescribeKey",
  #      "kms:GenerateDataKey"
  #  ]
  #  resources = [local.data_aws_kms_key_account_secretsmanager_master_arn ]
  #}

  statement {
    effect = "Allow"
    actions = [
        "s3:*",
        "s3-object-lambda:*"
    ]
     resources = [
      "arn:aws-us-gov:s3:::aws-windows-downloads-us-gov-west-1/*"
     ]
  }
}

#data "aws_kms_key" "account_secretsmanager_master" {
#        key_id = local.data_aws_kms_key_account_secretsmanager_master_alias
#}
#
#locals {
#        data_aws_kms_key_account_secretsmanager_master_alias = "alias/${var.globals["account_application"]}-${var.globals["environment_shorthand"]}-secretsmanager-master-kms"
#        data_aws_kms_key_account_secretsmanager_master_id    = data.aws_kms_key.account_secretsmanager_master.id
#        data_aws_kms_key_account_secretsmanager_master_arn   = data.aws_kms_key.account_secretsmanager_master.arn
#}