<<<<<<< HEAD
# Dynamic String HTML Page with AWS Lambda and API Gateway

## Project Overview
This project provisions an AWS service using Terraform that serves a simple HTML page. The page displays a dynamic string which can be updated without re-deployment. The string is fetched from AWS SSM Parameter Store by an AWS Lambda function, which is triggered by an API Gateway endpoint.

## Deployment Instructions

### Pre-requisites
- AWS CLI
- Terraform
- GitHub Account

### Cloning the Repository
```bash
git clone <repo-url>
cd <repo-name>

Setting up AWS Credentials
 AWS credentials are configured.

Terraform Initialization--
terraform init
Deploying Infrastructure--
 terraform apply
Accessing the Page---
terraform output api_gateway_url

To update the dynamic string, use the following AWS CLI command:

aws ssm put-parameter --name "/dynamic_string" --value "New Dynamic String" --type "String" --overwrite

Testing the Solution
Access the API Gateway URL.
Modify the dynamic string in AWS SSM.
Refresh the page to see the updated string.
=======
# aws-dynamic-page
 Dynamic content change - terraform
>>>>>>> fcf27d885a7a853aa54bb5b8b53e1b93ffd0c5ba
