terraform {

  required_providers {

    aws = {

      source  = "hashicorp/aws"

      version = "~> 4.16"

    }

  }



  required_version = ">= 1.2.0"

}



provider "aws" {

  region  = "us-west-2"
}

module "vpc" {
  source = "./modules/vpc"
}

module "alb" {
  source = "./modules/alb"
  vpc = module.vpc.main.id
  subnet3 = module.vpc.subnet3.id
  subnet2 = module.vpc.subnet4.id
  security_group = module.vpc.security_group.id
  depends_on = [module.vpc]
}

module "ecs" {
  source = "./modules/ecs"
  ecs_tg = module.alb.ecs_tg.arn
  subnet = module.vpc.subnet.id
  subnet2 = module.vpc.subnet2.id
  security_group = module.vpc.security_group.id
  depends_on = [module.alb,module.vpc]
}

module "lambda" {
  source = "./modules/lambda"
}

module "lambda_modify" {
  source = "./modules/lambda_modify"
  lambda_arn = module.lambda.ecs_lambda.arn
  bridge_arn = module.eventbridge.bridge.name
  lambda_name = module.lambda.ecs_lambda.function_name
  depends_on = [module.lambda,module.eventbridge]
}

module "eventbridge" {
 source = "./modules/eventbridge"
 lambda_redeploy = module.lambda.ecs_lambda.arn
}

module "api_gateway" {
  source = "./modules/api_gateway"
  ecs_alb_dns = module.alb.alb_dns
  depends_on = [module.alb]
}
