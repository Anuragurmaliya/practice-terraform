# vpc creating

resource "aws_vpc" "dev" {
    cidr_block =  "10.0.0.0/16"
    tags = {
        name = "cus-vpc"
    }
}

# create subnet

resource "aws_subnet" "prod" {
 vpc_id = aws_vpc.dev.id
 cidr_block = "10.0.0.0/24"
 tags = {
   name = "cus-sub"
 }
  
}

# internet gateway

resource "aws_internet_gateway" "test" {
    vpc_id = aws_vpc.dev.id
    tags = {
      name= "my-gateway"
    }
    
}


#creating route table and give internet gateway
resource "aws_route_table" "text" {
  vpc_id = aws_vpc.dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test.id
  }
  tags = {
    name = "my-rt"
  }

}

# subnet assosiation

resource "aws_route_table_association" "name" {
    subnet_id = aws_subnet.prod.id
    route_table_id = aws_route_table.text.id
    
     

}

#security group cretion
resource "aws_security_group" "tesla" {
    vpc_id = aws_vpc.dev.id
    name = "allow_tls"
    tags = {
      name = "my-sg" 
    }

    ingress {
        description = "allow ssh"
        from_port = "22"
        to_port = "22"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }
     ingress {
        description = "HTTP from VPC"
        from_port = "80"
        to_port = "80"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }
    egress {
        description = "allow tls vpc"
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }

    
}

resource "aws_instance" "hari" {

    ami = var.ami_id
    instance_type = var.instance_type
    key_name = var.key_name
    vpc_security_group_ids = [aws_security_group.tesla.id]
    subnet_id = aws_subnet.prod.id
    tags = {
      name = "anurag"
    }
  
}