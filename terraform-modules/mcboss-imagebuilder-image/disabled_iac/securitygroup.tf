resource "aws_security_group" "this" { ### FIXME: convert to PPSM
  name        = "${var.image_name}_image_builder_sg"
  description = "Security group for AWS Image Builder ${var.image_name}"
  vpc_id      = var.globals["vpc_id"]

  # Notice we removed the inline 'egress' block entirely

  tags = {
    Name = "${var.image_name}_image_builder_sg"
  }
}

# Standalone Egress Rule for Port 443 (HTTPS)
resource "aws_vpc_security_group_egress_rule" "https" { ### FIXME: convert to PPSM
  security_group_id = aws_security_group.this.id
  
  description = "Allow HTTPS outbound for Image Builder "
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}