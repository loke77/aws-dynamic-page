 
provider "aws" {
  region = "us-east-1"  
}

resource "aws_ssm_parameter" "dynamic_string" {
  name  = "/dynamic_string"
  type  = "String"
  value = "Hello, World!"
}
resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "lambda-basic-execution"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_lambda_function" "dynamic_page" {
  function_name = "dynamic-page-lambda"
  role          = aws_iam_role.lambda_exec.arn  # Correct IAM Role Reference
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = "lambda/lambda_function.zip"
  source_code_hash = filebase64sha256("lambda/lambda_function.zip")
}

#api gateway
resource "aws_api_gateway_rest_api" "dynamic_page_api" {
  name        = "DynamicPageAPI"
  description = "API Gateway to serve dynamic HTML content"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.dynamic_page_api.id
  parent_id   = aws_api_gateway_rest_api.dynamic_page_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.dynamic_page_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.dynamic_page_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.dynamic_page.invoke_arn
}

resource "aws_api_gateway_deployment" "dynamic_page" {
  depends_on = [aws_api_gateway_integration.lambda]
  rest_api_id = aws_api_gateway_rest_api.dynamic_page_api.id
  stage_name  = "prod"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dynamic_page.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.dynamic_page_api.execution_arn}/*/*"
}
output "api_gateway_url" {
  value = aws_api_gateway_deployment.dynamic_page.invoke_url
}

