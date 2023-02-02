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

data "archive_file" "add-items" {
  type = "zip"

  source_dir  = "${path.module}/dist/AddItem"
  output_path = "${path.module}/build/addItem.zip"
}

resource "aws_s3_object" "lambda-add-items" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "addItem.zip"
  source = data.archive_file.add-items.output_path

  etag = filemd5(data.archive_file.add-items.output_path)
}


resource "aws_lambda_function" "AddItemFunction" {
  function_name = "AddItem"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda-add-items.key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.add-items.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "addItem" {
  name = "/aws/lambda/${aws_lambda_function.AddItemFunction.function_name}"

  retention_in_days = 30
}

data "archive_file" "get-items" {
  type = "zip"

  source_dir  = "${path.module}/dist/GetItems"
  output_path = "${path.module}/build/getItems.zip"
}

resource "aws_s3_object" "lambda-get-items" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "getItems.zip"
  source = data.archive_file.get-items.output_path

  etag = filemd5(data.archive_file.get-items.output_path)
}


resource "aws_lambda_function" "GetItemsFunction" {
  function_name = "GetItems"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda-get-items.key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.get-items.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "getItems" {
  name = "/aws/lambda/${aws_lambda_function.GetItemsFunction.function_name}"

  retention_in_days = 30
}

data "archive_file" "get-items-paginated" {
  type = "zip"

  source_dir  = "${path.module}/dist/GetPaginatedItems"
  output_path = "${path.module}/build/getPaginatedItems.zip"
}

resource "aws_s3_object" "lambda-get-items-paginated" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "getItemsPaginated.zip"
  source = data.archive_file.get-items-paginated.output_path

  etag = filemd5(data.archive_file.get-items-paginated.output_path)
}


resource "aws_lambda_function" "GetPaginatedItemsFunction" {
  function_name = "GetPaginatedItems"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda-get-items-paginated.key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.get-items-paginated.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      DB_URL = var.DB_URL
    }
  }
}

resource "aws_cloudwatch_log_group" "getPaginatedItems" {
  name = "/aws/lambda/${aws_lambda_function.GetPaginatedItemsFunction.function_name}"

  retention_in_days = 30
}

data "archive_file" "add-review" {
  type = "zip"

  source_dir  = "${path.module}/dist/AddReview"
  output_path = "${path.module}/build/AddReview.zip"
}

resource "aws_s3_object" "lambda-add-review" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "AddReview.zip"
  source = data.archive_file.add-review.output_path

  etag = filemd5(data.archive_file.add-review.output_path)
}


resource "aws_lambda_function" "AddReviewFunction" {
  function_name = "AddReview"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda-add-review.key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.add-review.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      DB_URL = var.DB_URL
    }
  }
}

resource "aws_cloudwatch_log_group" "addReview" {
  name = "/aws/lambda/${aws_lambda_function.AddReviewFunction.function_name}"

  retention_in_days = 30
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
