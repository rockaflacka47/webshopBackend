# webshopBackend

This webshop was built as a way for me to practice using React with Material UI, practice working with MongoDB, and to learn more about AWS services such as lambda.

The front end can be found at https://github.com/rockaflacka47/commerceShop

If you would like access to an admin account for the Add Item page please get in contact with me.

# Usage Instructions

## Pre-Requirements

1. [Terraform Installed](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
2. [AWS CLI installed](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3. [AWS admin credentials configured](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html)
4. [AWS IAM key/secret for a role with s3 permission](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Integrating.Authorizing.IAM.S3CreatePolicy.html)
5. [A Stripe API key](https://stripe.com/docs/keys)
6. [A MongoDB connection url](https://www.mongodb.com/docs/compass/current/connect/)
7. A mongodb named "db" with two collections "User" and "Item"
8. An s3 bucket in the same region as your variables.tf aws_region variable.
9. npm installed

## Set up

1. Run `npm install`
2. Create a .env file in the root directory with the following variables:
   - DB_URL = "(mongo connection url)"
   - STRIPE_KEY = "(stripe api key)"
   - BUCKET_NAME = "(name of bucket to store images)"
   - IAM_USER_KEY = "(public key for user with s3 permissions)"
   - IAM_USER_SECRET = "(secret key for user with s3 permissions)"
   - SIGN_TOKEN = "(any string, used to sign and verify tokens)"
   - EMAIL_USER = "(email client user)"
   - EMAIL_PASS = "(email client password)"

3. Create a variables.tf file in the root directory with the same variables as well as:
   - aws_region
   - the format for .tf variables is 
   `variable "(variable name)" {
       default = "(default value)"
   }`
4. Run `terraform init`
5. Run `npm run package`
5. (optional) Run `terraform plan` to see the changes that will be made.
6. Run `npm run pd` to run prettier on all src files, funpack, and terraform apply.

## Verification

You can verify the endpoints were deployed by logging into AWS and checking your lambda functions. You can also change the URLS in the accompanying front end repo (api.tsx) and test the entire application.

## Valid Instructions

1. `npm run package` - runs prettier and funpack
2. `npm run deploy` - runs prettier and terraform apply
3. `npm run pd` - runs prettier, funpack, and terraform apply --auto-approve
