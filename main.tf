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

data "archive_file" "create-payment-intent" {
  type = "zip"

  source_dir  = "${path.module}/dist/CreatePaymentIntent"
  output_path = "${path.module}/build/CreatePaymentIntent.zip"
}

resource "aws_s3_object" "lambda-create-payment-intent" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "CreatePaymentIntent.zip"
  source = data.archive_file.create-payment-intent.output_path

  etag = filemd5(data.archive_file.create-payment-intent.output_path)
}


resource "aws_lambda_function" "CreatePaymentIntentFunction" {
  function_name = "CreatePaymentIntent"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda-create-payment-intent.key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.create-payment-intent.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      STIPRE_KEY = var.STRIPE_KEY
    }
  }
}

resource "aws_cloudwatch_log_group" "createPaymentIntent" {
  name = "/aws/lambda/${aws_lambda_function.CreatePaymentIntentFunction.function_name}"

  retention_in_days = 30
}

data "archive_file" "create-user" {
  type = "zip"

  source_dir  = "${path.module}/dist/CreateUser"
  output_path = "${path.module}/build/CreateUser.zip"
}

resource "aws_s3_object" "lambda-create-user" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "CreateUser.zip"
  source = data.archive_file.create-user.output_path

  etag = filemd5(data.archive_file.create-user.output_path)
}


resource "aws_lambda_function" "CreateUserFunction" {
  function_name = "CreateUser"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda-create-user.key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.create-user.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      DB_URL = var.DB_URL
    }
  }
}

resource "aws_cloudwatch_log_group" "createUser" {
  name = "/aws/lambda/${aws_lambda_function.CreateUserFunction.function_name}"

  retention_in_days = 30
}

data "archive_file" "get-count-items" {
  type = "zip"

  source_dir  = "${path.module}/dist/GetCountItems"
  output_path = "${path.module}/build/GetCountItems.zip"
}

resource "aws_s3_object" "lambda-get-count-items" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "GetCountItems.zip"
  source = data.archive_file.get-count-items.output_path

  etag = filemd5(data.archive_file.get-count-items.output_path)
}


resource "aws_lambda_function" "GetCountItemsFunction" {
  function_name = "GetCountItems"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda-get-count-items.key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.get-count-items.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      DB_URL = var.DB_URL
    }
  }
}

resource "aws_cloudwatch_log_group" "getCountItems" {
  name = "/aws/lambda/${aws_lambda_function.GetCountItemsFunction.function_name}"

  retention_in_days = 30
}

data "archive_file" "get-item" {
  type = "zip"

  source_dir  = "${path.module}/dist/GetItem"
  output_path = "${path.module}/build/GetItem.zip"
}

resource "aws_s3_object" "lambda-get-item" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "GetItem.zip"
  source = data.archive_file.get-item.output_path

  etag = filemd5(data.archive_file.get-item.output_path)
}


resource "aws_lambda_function" "GetItemFunction" {
  function_name = "GetItem"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda-get-item.key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.get-item.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      DB_URL = var.DB_URL
    }
  }
}

resource "aws_cloudwatch_log_group" "getItem" {
  name = "/aws/lambda/${aws_lambda_function.GetItemFunction.function_name}"

  retention_in_days = 30
}

data "archive_file" "get-items-by-id" {
  type = "zip"

  source_dir  = "${path.module}/dist/GetItemsById"
  output_path = "${path.module}/build/GetItemsById.zip"
}

resource "aws_s3_object" "lambda-get-items-by-id" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "GetItemsById.zip"
  source = data.archive_file.get-items-by-id.output_path

  etag = filemd5(data.archive_file.get-items-by-id.output_path)
}

resource "aws_lambda_function" "GetItemsByIdFunction" {
  function_name = "GetItemsById"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda-get-items-by-id.key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.get-items-by-id.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      DB_URL = var.DB_URL
    }
  }
}

resource "aws_cloudwatch_log_group" "getItemsById" {
  name = "/aws/lambda/${aws_lambda_function.GetItemsByIdFunction.function_name}"

  retention_in_days = 30
}

data "archive_file" "push-to-cart" {
  type = "zip"

  source_dir  = "${path.module}/dist/PushToCart"
  output_path = "${path.module}/build/PushToCart.zip"
}

resource "aws_s3_object" "lambda-push-to-cart" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "PushToCart.zip"
  source = data.archive_file.push-to-cart.output_path

  etag = filemd5(data.archive_file.push-to-cart.output_path)
}

resource "aws_lambda_function" "PushToCartFunction" {
  function_name = "PushToCart"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda-push-to-cart.key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.push-to-cart.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      DB_URL = var.DB_URL
    }
  }
}

resource "aws_cloudwatch_log_group" "pushToCart" {
  name = "/aws/lambda/${aws_lambda_function.PushToCartFunction.function_name}"

  retention_in_days = 30
}

data "archive_file" "remove-from-cart" {
  type = "zip"

  source_dir  = "${path.module}/dist/RemoveFromCart"
  output_path = "${path.module}/build/RemoveFromCart.zip"
}

resource "aws_s3_object" "lambda-remove-from-cart" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "RemoveFromCart.zip"
  source = data.archive_file.remove-from-cart.output_path

  etag = filemd5(data.archive_file.remove-from-cart.output_path)
}

resource "aws_lambda_function" "RemoveFromCartFunction" {
  function_name = "RemoveFromCart"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda-remove-from-cart.key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.remove-from-cart.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      DB_URL = var.DB_URL
    }
  }
}

resource "aws_cloudwatch_log_group" "removeFromCart" {
  name = "/aws/lambda/${aws_lambda_function.RemoveFromCartFunction.function_name}"

  retention_in_days = 30
}

data "archive_file" "signin" {
  type = "zip"

  source_dir  = "${path.module}/dist/Signin"
  output_path = "${path.module}/build/Signin.zip"
}

resource "aws_s3_object" "lambda-signin" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "Signin.zip"
  source = data.archive_file.signin.output_path

  etag = filemd5(data.archive_file.signin.output_path)
}

resource "aws_lambda_function" "SigninFunction" {
  function_name = "Signin"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda-signin.key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.signin.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      DB_URL = var.DB_URL,
      SIGN_TOKEN = var.SIGN_TOKEN
    }
  }
}

resource "aws_cloudwatch_log_group" "signinLog" {
  name = "/aws/lambda/${aws_lambda_function.SigninFunction.function_name}"

  retention_in_days = 30
}

data "archive_file" "upload-image" {
  type = "zip"

  source_dir  = "${path.module}/dist/UploadImage"
  output_path = "${path.module}/build/UploadImage.zip"
}

resource "aws_s3_object" "lambda-upload-image" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "UploadImage.zip"
  source = data.archive_file.upload-image.output_path

  etag = filemd5(data.archive_file.upload-image.output_path)
}

resource "aws_lambda_function" "UploadImageFunction" {
  function_name = "UploadImage"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda-upload-image.key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.upload-image.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      IAM_USER_KEY = var.IAM_USER_KEY,
      IAM_USER_SECRET = var.IAM_USER_SECRET,
      BUCKET_NAME = var.BUCKET_NAME
    }
  }
}

resource "aws_cloudwatch_log_group" "uploadImage" {
  name = "/aws/lambda/${aws_lambda_function.UploadImageFunction.function_name}"

  retention_in_days = 30
}

data "archive_file" "stripe-success" {
  type = "zip"

  source_dir  = "${path.module}/dist/StripeSuccess"
  output_path = "${path.module}/build/StripeSuccess.zip"
}

resource "aws_s3_object" "lambda-stripe-success" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "StripeSuccess.zip"
  source = data.archive_file.stripe-success.output_path

  etag = filemd5(data.archive_file.stripe-success.output_path)
}

resource "aws_lambda_function" "StripeSuccessFunction" {
  function_name = "StripeSuccess"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda-stripe-success.key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.stripe-success.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      EMAIL_USER = var.EMAIL_USER,
      EMAIL_PASS = var.EMAIL_PASS
    }
  }
}

resource "aws_cloudwatch_log_group" "stripeSuccess" {
  name = "/aws/lambda/${aws_lambda_function.StripeSuccessFunction.function_name}"

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
