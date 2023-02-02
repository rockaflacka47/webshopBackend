# webshopBackend

This webshop was built as a way for me to practice using React with Material UI, practice working with MongoDB, and to learn more about AWS services such as lambda.

The front end can be found at https://github.com/rockaflacka47/commerceShop

This repo is private due to not wanting to pay for this project more then necessary there are values that should be retrieved from AWS key management, or another provider, that are hard coded in.

If you would like access to an admin account for the Add Item page please get in contact with me.

# Usage Instructions

## Pre-Requirements

1. Terraform installed - https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
2. AWS CLI installed - https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
3. AWS admin credentials configured - https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html
4. AWS IAM key/secret for a role with s3 upload permission
4. A Stripe API key - https://stripe.com/docs/keys

## Set up

1. Run `npm install`.
2. Create a .env file in the root directory with the following variables:
   - DB_URL: string
   - STRIPE_KEY: string
   - BUCKET_NAME: string
   - IAM_USER_KEY: string
   - IAM_USER_SECRET: string
   - SIGN_TOKEN: string
   - EMAIL_USER: string
   - EMAIL_PASS: string
3. Create a variables.tf file in the root directory with the same variables as well as:
   - aws_region
4. Run `terraform init`.
5. (optional) Run `terraform plan` to see the changes that will be made.
6. Run `npm run pd` to run prettier on all src files, funpack, and terraform apply.

## Verification

You can verify the endpoints were deployed correctly by logging into AWS and checking your lambda functions.
