resource "aws_cognito_user_pool" "royal_user_pool" {
  name = "royalUserPool"

  email_verification_subject = "Your Verification Code"
  email_verification_message = "Please use the following code: {####}"
  alias_attributes           = ["email"]
  auto_verified_attributes   = ["email"]

  password_policy {
    minimum_length    = 6
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  username_configuration {
    case_sensitive = false
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      min_length = 7
      max_length = 256
    }
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "name"
    required                 = true

    string_attribute_constraints {
      min_length = 3
      max_length = 256
    }
  }
}

resource "aws_cognito_user_pool_client" "royal_user_pool_client" {
  name                         = "royalUserPoolClient"
  explicit_auth_flows          = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]

  user_pool_id = aws_cognito_user_pool.royal_user_pool.id
}



resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "royal-api"
  description = "Royal API Gateway"
  binary_media_types = ["*"]
}

resource "aws_api_gateway_resource" "check_in_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "check-in"
}

resource "aws_api_gateway_method" "check_in_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.check_in_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.api_authorizer.id

}

resource "aws_api_gateway_integration" "check_in_api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.check_in_resource.id
  http_method             = aws_api_gateway_method.check_in_api_method.http_method
  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${var.ecs_alb_dns}"
}

resource "aws_api_gateway_method_response" "check_in_method_response" {
  for_each    = toset(var.api_status_response)
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.check_in_resource.id
  http_method = aws_api_gateway_method.check_in_api_method.http_method
  status_code = each.value
}

resource "aws_api_gateway_integration_response" "integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.check_in_resource.id
  http_method = aws_api_gateway_method.check_in_api_method.http_method
  status_code = "200"

}

resource "aws_api_gateway_authorizer" "api_authorizer" {
  name          = "CognitoUserPoolAuthorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  provider_arns = [aws_cognito_user_pool.royal_user_pool.arn]
}

resource "aws_api_gateway_deployment" "test" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name = "test"
  depends_on = [aws_api_gateway_method.check_in_api_method]
   triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.rest_api.binary_media_types))
  }

}

resource "aws_api_gateway_stage" "test" {
  deployment_id = aws_api_gateway_deployment.test.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = "test"
}

