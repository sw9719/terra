variable "ecs_tg" {
   type = string
}

variable "task_nodeapp" {
  default = "arn:aws:ecs:us-west-2:656554891976:task-definition/nodeapp:8"
}

variable "subnet" {
   type = string
}

variable "subnet2" {
   type = string
}

variable "security_group" {
   type = string
}
