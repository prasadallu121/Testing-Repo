terraform {
  backend "s3" {
    bucket         = "prasad-terraformtesting"
    key            = "s3-backend/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "Terraform-Testing"
  }
}