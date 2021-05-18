data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["CentOS 7*"]
  }
  owners = ["amazon"]
}

resource "aws_security_group" "main" {
  description = "Control kubernetes inbound and outbound access"
  name        = "${local.prefix}-kubernetes-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-kubernetes" })
  )

}

resource "aws_key_pair" "main" {
  key_name   = "kubernetes-key"
  public_key = file("keys/key.pub")
}

resource "aws_instance" "main" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.small"
  key_name      = aws_key_pair.main.key_name
  subnet_id     = aws_subnet.main.id

  vpc_security_group_ids = [
    aws_security_group.main.id
  ]

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file("keys/key")
      host = aws_instance.main.public_ip
    }
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-master-0" })
  )
}

