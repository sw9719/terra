resource "aws_ecs_cluster" "ecs_cluster" {
  name = "white-hart"

}


resource "aws_ecs_service" "nodeapp" {
  name            = "nodeapp"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = var.task_nodeapp
  desired_count   = 3
  deployment_minimum_healthy_percent = "10"
  deployment_maximum_percent = "600"
  force_new_deployment = "true"
  launch_type = "FARGATE"

  network_configuration {
    subnets = [var.subnet, var.subnet2]
    security_groups = [var.security_group]
  }


  load_balancer {
    target_group_arn = var.ecs_tg
    container_name   = "nodeapp"
    container_port   = 3000
  }

}

