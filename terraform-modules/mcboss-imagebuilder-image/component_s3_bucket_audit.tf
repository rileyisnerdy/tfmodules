resource "aws_s3_bucket" "audit" {
        ### FIXME: ADD TOGGLE FOR IF-INCLUDED IN SPECIFIC COMPONENT
        bucket        = local.audit_bucket_name ### defined in variables_locals.tf; bucket per pipeline so the bucket policy can effectively self manage
        force_destroy = false ### FIXME Convert to toggle variable
}

resource "aws_s3_bucket_public_access_block" "audit" {
        bucket                  = aws_s3_bucket.audit.id
        block_public_acls       = true
        block_public_policy     = true
        ignore_public_acls      = true
        restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "audit" {
        bucket = aws_s3_bucket.audit.id

        rule {
                apply_server_side_encryption_by_default {
                        sse_algorithm = "AES256"
                }
        }
}

resource "aws_s3_bucket_versioning" "audit" { ### FIXME Convert to toggle variable
        bucket = aws_s3_bucket.audit.id

        versioning_configuration {
                status = "Enabled"
        }
}

resource "aws_s3_bucket_policy" "audit" {
        bucket = aws_s3_bucket.audit.id
        policy = data.aws_iam_policy_document.resource_policy_s3_bucket_audit.json
}

data "aws_iam_policy_document" "resource_policy_s3_bucket_audit" {
        statement {
                sid        = "AllowAdmins"
                effect     = "Allow"
                actions    = [ "s3:*" ]
                principals {
                        type        = "AWS"
                        identifiers = [ "arn:aws-us-gov:iam::${var.globals["account_id"]}:role/mso_admins" ]
                }
                resources  = [ aws_s3_bucket.audit.arn,
                            "${aws_s3_bucket.audit.arn}/*"
                ]
        }

        statement {
                sid        = "AllowEC2RoleBucketAccess"
                effect     = "Allow"
                actions    = [ "s3:ListBucket",
                                "s3:GetBucketLocation"
                ]
                principals {
                        type        = "AWS"
                        identifiers = [ aws_iam_role.this.arn ]
                }
                resources = [ aws_s3_bucket.audit.arn ]
        }

        statement {
                sid        = "AllowEC2RoleGetObjectAccess"
                effect     = "Allow"
                actions    = [ "s3:GetObject",
                               "s3:PutObject",
                               "s3:GetObjectVersion"
                ]
                principals {
                        type        = "AWS"
                        identifiers = [ aws_iam_role.this.arn ]
                }
                resources = [ "${aws_s3_bucket.audit.arn}/*" ]
        }

}


# data "aws_iam_policy_document" "sqs_s3_archivedb" {
#         source_policy_documents = [ data.aws_iam_policy_document.kms_sqs_s3_archivedb_root_allowall.json,
#                                     data.aws_iam_policy_document.kms_sqs_s3_archivedb_mso_administrators.json,
#                                     data.aws_iam_policy_document.kms_sqs_s3_archivedb_eps_s3_service.json
#                                     #data.aws_iam_policy_document.kms_sqs_s3_archivedb_cross_account_identities.json
#         ]
# }
