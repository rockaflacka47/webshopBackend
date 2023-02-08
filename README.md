# webshopBackend

This webshop was built as a way for me to practice using React with Material UI, practice working with MongoDB, and to learn more about AWS services such as lambda.

The front end can be found at https://github.com/rockaflacka47/commerceShop

If you would like access to an admin account for the Add Item page please get in contact with me.

# Usage Instructions

## Pre-Requirements

1. [Terraform Installed](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
2. [AWS CLI installed](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3. [AWS admin credentials configured](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html)
4. [AWS IAM key/secret for a role with lambda basic execution](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Integrating.Authorizing.IAM.S3CreatePolicy.html)
5. [A Stripe API key](https://stripe.com/docs/keys)
6. [A MongoDB connection url](https://www.mongodb.com/docs/compass/current/connect/)
7. A mongodb named "DB" with two collections "User" and "Item"
8. An s3 bucket in the same region as your variables.tf aws_region variable.
9. Access to the MongoDB. Only Admin accounts are allowed to add items so once you create an account you will have to manually 
add `Type: "ADMIN"` to that account.

## Set up

1. Run `npm install`.
2. Create a .env file in the root directory with the following variables:
   - DB_URL(mongo): string
   - STRIPE_KEY: string
   - BUCKET_NAME(to store uploaded images): string
   - IAM_USER_KEY: string
   - IAM_USER_SECRET: string
   - SIGN_TOKEN(any string, used for signing and verifying passwords): string
   - EMAIL_USER: string
   - EMAIL_PASS: string
3. Create a variables.tf file in the root directory with the same variables as well as:
   - aws_region
4. Run `terraform init`.
5. (optional) Run `terraform plan` to see the changes that will be made.
6. Run `npm run pd` to run prettier on all src files, funpack, and terraform apply.

## Verification

You can verify the endpoints were deployed by logging into AWS and checking your lambda functions. You can also change the URLS in the accompanying front end repo (api.js) and test the entire application.

## Valid Instructions

1. `npm run package` - runs prettier and funpack
2. `npm run deploy` - runs prettier and terraform apply
3. `npm run pd` - runs prettier, funpack, and terraform apply --auto-approve
