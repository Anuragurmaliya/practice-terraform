resource "aws_s3_bucket" "dev" {
    bucket = "first-dynamodb-bucket"
    
  
}

resource "aws_s3_bucket_versioning" "name" {
    bucket = aws_s3_bucket.dev.id
    versioning_configuration {
      status = "Enabled"
    }
  
}
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "terraform-state-lock-dynamo-2"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
 
  attribute {
    name = "LockID"
    type = "S"
  }
  depends_on = [ aws_s3_bucket.dev ]
}
