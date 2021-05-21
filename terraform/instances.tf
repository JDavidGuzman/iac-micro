data "aws_ami" "linux" {
  most_recent = true
  filter {
    name   = "name"
    values = [var.ami]
  }
  owners = ["amazon"]
}

resource "aws_security_group" "k8s" {
  description = "Control kubernetes inbound and outbound access"
  name        = "${local.prefix}-master-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
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
    from_port   = 6443
    to_port     = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
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
    from_port   = 6443
    to_port     = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  tags = local.common_tags
}


resource "aws_security_group" "nodeport" {
  description = "Control kubernetes inbound and outbound access"
  name        = "${local.prefix}-nodeport-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 30000
    to_port     = 32767
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 30000
    to_port     = 32767
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_key_pair" "main" {
  key_name   = "kubernetes-key"
  public_key = file("keys/key.pub")
}

resource "aws_instance" "master" {
  for_each = var.master_num

  ami           = data.aws_ami.linux.id
  instance_type = "t3.small"
  key_name      = aws_key_pair.main.key_name
  subnet_id     = aws_subnet.main[each.key].id

  vpc_security_group_ids = [
    aws_security_group.k8s.id
  ]

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file("keys/key")
      host        = self.public_ip
    }
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-master-${each.value}" })
  )
}

resource "aws_instance" "worker" {
  for_each = var.worker_num

  ami           = data.aws_ami.linux.id
  instance_type = "t3.small"
  key_name      = aws_key_pair.main.key_name
  subnet_id     = aws_subnet.main[each.key].id

  vpc_security_group_ids = [
     aws_security_group.k8s.id,
    aws_security_group.nodeport.id
  ]

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file("keys/key")
      host        = self.public_ip
    }
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-worker-${each.value}" })
  )
}
