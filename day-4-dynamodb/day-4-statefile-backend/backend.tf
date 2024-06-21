terraform {
  backend "s3" {
    bucket = "first-dynamodb-bucket"
    key = "terraform.tfstate"
    region = "ap-south-1"
    dynamodb_table = "terraform-state-lock-dynamo-2" # DynamoDB table used for state locking, note: first run day-4-statefile-create=s3
    encrypt        = true

    
  }
}