# SSM Parameter to store the bucket name so the YAML component can find it dynamically
resource "aws_ssm_parameter" "audit_bucket_name" {
  name  = "/imagebuilder/${var.image_name}/audit_bucket"
  type  = "String"
  value = var.audit_bucket_name
}