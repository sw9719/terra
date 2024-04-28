data "archive_file" "code" {
  type        = "zip"
  source_dir  = "${path.module}/code/"
  output_path = "${path.module}/code.zip"
}

resource "aws_lambda_function" "test_lambda" {
  function_name = "redeploy_ecs"
  filename = "${path.module}/code.zip"
  source_code_hash = data.archive_file.code.output_base64sha256
  role = var.deploy_arn
  handler = "code.lambda_handler"
  runtime = "python3.10"

}


output "ecs_lambda" {
  value = aws_lambda_function.test_lambda
}
