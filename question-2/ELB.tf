###########target group creation and health check on port 80##########
resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.custom-vpc.id}"

  health_check {
    path     = "/"
    port     = 80
    protocol = "HTTP"
  }
}
##########loadbalancer creation######
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnet_mapping {
    subnet_id     = aws_subnet.subnet-1.id
  }

  subnet_mapping {
    subnet_id     = aws_subnet.subnet-2.id
  }

}
###############listener creation###########
resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}
################target attachement (target is test instance)
resource "aws_lb_target_group_attachment" "my_attachment" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.test.id
}
