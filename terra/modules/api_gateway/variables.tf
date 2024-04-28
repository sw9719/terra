variable "api_status_response" {
   type = list
   default = ["200","300","400","500"]
} 

variable "ecs_alb_dns" {
   type = string
}
