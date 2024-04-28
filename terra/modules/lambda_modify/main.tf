resource "aws_lambda_alias" "test_alias" {
  name             = "testalias"
  description      = "a sample description"
  function_name    = var.lambda_name
  function_version = "$LATEST"
}

resource "aws_lambda_permission" "allow_Eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_target.lambda_redeploy.arn
  qualifier     = aws_lambda_alias.test_alias.name
}

resource "aws_cloudwatch_event_target" "lambda_redeploy" {
  rule      = var.bridge_arn
  target_id = "InvokeLambda"
  arn       = var.lambda_arn
}

