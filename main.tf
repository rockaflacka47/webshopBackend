terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

resource "random_pet" "lambda_bucket_name" {
  prefix = "webshop-terraform"
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = random_pet.lambda_bucket_name.id
  force_destroy = true
}

resource "aws_s3_bucket_acl" "lambda_bucket_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}

variable "lambdas" {
  description = "Map of Lambda function names and API gateway resource paths."
  type        = map(any)
  default = {
    signin = {
      name       = "Signin"
      path       = "DoLogin"
      source     = "dist/Signin"
      output     = "$build/Signin.zip"
      key        = "Signin.zip"
      httpMethod = "POST"
    },
    getPaginatedItems = {
      name       = "GetPaginatedItems"
      path       = "GetPaginatedItems"
      source     = "dist/GetPaginatedItems"
      output     = "$build/GetPaginatedItems.zip"
      key        = "GetPaginatedItems.zip"
      httpMethod = "POST"
    },
    getCountItems = {
      name       = "GetCountItems"
      path       = "GetCountItems"
      source     = "dist/GetCountItems"
      output     = "$build/GetCountItems.zip"
      key        = "GetCountItems.zip"
      httpMethod = "POST"
    },
    addItem = {
      name       = "AddItem"
      path       = "AddItem"
      source     = "dist/AddItem"
      output     = "$build/AddItem.zip"
      key        = "AddItem.zip"
      httpMethod = "POST"
    },
    addReview = {
      name       = "AddReview"
      path       = "AddReview"
      source     = "dist/AddReview"
      output     = "$build/AddReview.zip"
      key        = "AddReview.zip"
      httpMethod = "POST"
    },
    createPaymentIntent = {
      name       = "CreatePaymentIntent"
      path       = "CreatePaymentIntent"
      source     = "dist/CreatePaymentIntent"
      output     = "$build/CreatePaymentIntent.zip"
      key        = "CreatePaymentIntent.zip"
      httpMethod = "POST"
    },
    createUser = {
      name       = "CreateUser"
      path       = "CreateUser"
      source     = "dist/CreateUser"
      output     = "$build/CreateUser.zip"
      key        = "CreateUser.zip"
      httpMethod = "POST"
    },
    getItem = {
      name       = "GetItem"
      path       = "GetItem"
      source     = "dist/GetItem"
      output     = "$build/GetItem.zip"
      key        = "GetItem.zip"
      httpMethod = "POST"
    },
    getItems = {
      name       = "GetItems"
      path       = "GetItems"
      source     = "dist/GetItems"
      output     = "$build/GetItems.zip"
      key        = "GetItems.zip"
      httpMethod = "POST"
    },
    getItemsById = {
      name       = "GetItemsById"
      path       = "GetItemsById"
      source     = "dist/GetItemsById"
      output     = "$build/GetItemsById.zip"
      key        = "GetItemsById.zip"
      httpMethod = "POST"
    },
    pushToCart = {
      name       = "PushToCart"
      path       = "PushToCart"
      source     = "dist/PushToCart"
      output     = "$build/PushToCart.zip"
      key        = "PushToCart.zip"
      httpMethod = "POST"
    },
    removeFromCart = {
      name       = "RemoveFromCart"
      path       = "RemoveFromCart"
      source     = "dist/RemoveFromCart"
      output     = "$build/RemoveFromCart.zip"
      key        = "RemoveFromCart.zip"
      httpMethod = "POST"
    },
    uploadImage = {
      name       = "UploadImage"
      path       = "UploadImage"
      source     = "dist/UploadImage"
      output     = "$build/UplaodImage.zip"
      key        = "UploadImage.zip"
      httpMethod = "POST"
    },
    stripeSuccess = {
      name       = "StripeSuccess"
      path       = "StripeSuccess"
      source     = "dist/StripeSuccess"
      output     = "$build/StripeSuccess.zip"
      key        = "StripeSuccess.zip"
      httpMethod = "POST"
    },
    clearCart = {
      name       = "ClearCart"
      path       = "ClearCart"
      source     = "dist/ClearCart"
      output     = "$build/ClearCart.zip"
      key        = "ClearCart.zip"
      httpMethod = "POST"
    }
  }
}

data "archive_file" "zips" {
  for_each = var.lambdas
  type     = "zip"

  source_dir  = each.value.source
  output_path = each.value.output
}

resource "aws_s3_object" "uploaded-items" {
  for_each = var.lambdas
  bucket   = aws_s3_bucket.lambda_bucket.id

  key    = each.value.key
  source = each.value.output

  etag = filemd5(each.value.output)
}

resource "aws_lambda_function" "lambda-functions" {
  for_each      = var.lambdas
  function_name = each.value.name

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.uploaded-items[each.key].key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.zips[each.key].output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      DB_URL          = var.DB_URL,
      BUCKET_NAME     = var.BUCKET_NAME,
      IAM_USER_KEY    = var.IAM_USER_KEY,
      IAM_USER_SECRET = var.IAM_USER_SECRET,
      STRIPE_KEY      = var.STRIPE_KEY,
      SIGN_TOKEN      = var.SIGN_TOKEN,
      EMAIL_USER      = var.EMAIL_USER,
      EMAIL_PASS      = var.EMAIL_PASS
    }
  }
}

resource "aws_cloudwatch_log_group" "log-groups" {
  for_each = var.lambdas
  name     = "/aws/lambda/${aws_lambda_function.lambda-functions[each.key].function_name}"

  retention_in_days = 30
}

resource "aws_api_gateway_rest_api" "WebshopAPI" {
  name        = "WebshopAPI"
  description = "API Gateway for a webshop"
}

resource "aws_api_gateway_resource" "resources" {
  for_each    = var.lambdas
  rest_api_id = aws_api_gateway_rest_api.WebshopAPI.id
  parent_id   = aws_api_gateway_rest_api.WebshopAPI.root_resource_id
  path_part   = each.value.path
}

resource "aws_api_gateway_method" "methods" {
  for_each         = aws_api_gateway_resource.resources
  rest_api_id      = aws_api_gateway_rest_api.WebshopAPI.id
  resource_id      = each.value.id
  http_method      = var.lambdas[each.key].httpMethod
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "integration" {
  for_each                = aws_api_gateway_method.methods
  rest_api_id             = each.value.rest_api_id
  resource_id             = each.value.resource_id
  http_method             = each.value.http_method
  integration_http_method = var.lambdas[each.key].httpMethod
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda-functions[each.key].invoke_arn
}

resource "aws_lambda_permission" "apigw" {
    depends_on = [
      aws_api_gateway_integration.integration
    ]
  for_each      = var.lambdas
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = each.value.name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.WebshopAPI.execution_arn}/*/*"
}
module "api-gateway-enable-cors" {

  for_each = aws_api_gateway_resource.resources
  source   = "squidfunk/api-gateway-enable-cors/aws"
  version  = "0.3.3"
  # insert the 2 required variables here
  api_id          = aws_api_gateway_rest_api.WebshopAPI.id
  api_resource_id = each.value.id
}

resource "aws_api_gateway_deployment" "webshopapi" {
  depends_on = [
    aws_api_gateway_integration.integration
  ]

  rest_api_id = aws_api_gateway_rest_api.WebshopAPI.id
  stage_name  = "test"
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda_webshop"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
