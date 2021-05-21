resource "aws_lb" "main" {
  name               = "${local.prefix}-nlb"
  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.main : subnet.id]

  tags = local.common_tags
}

resource "aws_lb_target_group" "master_ssh" {
  name     = "${local.prefix}-ssh"
  port     = 22
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "master_ssh" {
  load_balancer_arn = aws_lb.main.arn
  port              = 22
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.master_ssh.arn
  }
}

resource "aws_lb_target_group_attachment" "master_ssh" {
  for_each = var.master_num

  target_group_arn = aws_lb_target_group.master_ssh.arn
  target_id        = aws_instance.master[each.key].id
  port             = 22
}

resource "aws_lb_target_group" "kapi" {
  name     = "${local.prefix}-kapi"
  port     = 6443
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "kapi" {
  load_balancer_arn = aws_lb.main.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kapi.arn
  }
}

resource "aws_lb_target_group_attachment" "master_kapi" {
  for_each = var.master_num

  target_group_arn = aws_lb_target_group.kapi.arn
  target_id        = aws_instance.master[each.key].id
  port             = 6443
}

resource "aws_lb_target_group_attachment" "worker_kapi" {
  for_each = var.master_num

  target_group_arn = aws_lb_target_group.kapi.arn
  target_id        = aws_instance.worker[each.key].id
  port             = 6443
}