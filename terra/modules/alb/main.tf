resource "aws_lb" "ecs_alb" {

 name               = "ecs-alb"

 internal           = false

 load_balancer_type = "application"

 security_groups    = [var.security_group]

 subnets            = [var.subnet3,var.subnet2]



 tags = {

   Name = "ecs-alb"

 }

}



resource "aws_lb_listener" "ecs_alb_listener" {

 load_balancer_arn = aws_lb.ecs_alb.arn

 port              = 80

 protocol          = "HTTP"



 default_action {

   type             = "forward"

   target_group_arn = aws_lb_target_group.ecs_tg.arn

 }

}



resource "aws_lb_target_group" "ecs_tg" {

 name        = "ecs-target-group"

 port        = 3000

 protocol    = "HTTP"

 target_type = "ip"

 vpc_id      = var.vpc




}


output "ecs_tg" {
   value = aws_lb_target_group.ecs_tg
}

output "alb_dns" {
   value = aws_lb.ecs_alb.dns_name
}
