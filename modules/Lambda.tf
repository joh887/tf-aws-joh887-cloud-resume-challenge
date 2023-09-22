data "aws_iam_policy_document" "m-lambda" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "m-lambda-dynamodb" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "LambdaIAM" {
  name               = "LambdaIAM"
  assume_role_policy = data.aws_iam_policy_document.m-lambda.json

  inline_policy {
    name   = "Lambda-DynamoDB"
    policy = data.aws_iam_policy_document.m-lambda-dynamodb.json
  }
}

variable "PayloadName" {
  default = "Payload.zip"
}

variable "FileName" {
  default = "GetMetric"
}

variable "Function" {
  default = "Execute"
}

data "archive_file" "Archive" {
  type        = "zip"
  source_file = "../Source/Python/${var.FileName}.py"
  output_path = var.PayloadName
}

resource "aws_lambda_function" "lf" {
  function_name = "IncrementVisitorMetric"
  filename      = var.PayloadName
  role          = aws_iam_role.LambdaIAM.arn

  source_code_hash = data.archive_file.Archive.output_base64sha256

  handler = "${var.FileName}.${var.Function}"
  runtime = "python3.9"
}

resource "aws_lambda_function_url" "lf_url" {
  function_name      = aws_lambda_function.lf.arn
  authorization_type = "NONE"

  cors {
    allow_methods = ["GET", "POST"]
    allow_origins = ["https://${var.R53DomainName}", "https://www.${var.R53DomainName}"]
  }
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lf.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}