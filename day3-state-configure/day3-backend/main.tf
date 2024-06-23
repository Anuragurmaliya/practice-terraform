resource "aws_instance" "name" {
    ami="ami-0e1d06225679bc1c5"
    key_name = "anuragkey3"
    instance_type = "t2.micro"
     tags = {
        Name= "anurag"
     }
  
}