#create vpc
resource "aws_vpc" "my-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "my-vpc"
    }
}
# creating pub subnet
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"
   tags = {
     Name = "pub-sub"
   }
}
# creationg pvt subnet
resource "aws_subnet" "private" {
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = "10.0.2.0/24"
    tags = {
      Name = "pvt-sub"
    }
  
}
# creating route table
resource "aws_internet_gateway" "my-gateway" {
    vpc_id = aws_vpc.my-vpc.id
    tags = {
     Name = "my-IG"
    }

  
}

# creating route table
resource "aws_route_table" "prod" {
    vpc_id = aws_vpc.my-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my-gateway.id
    }

    tags = {
      Name = "my-RT"
    }
  
}

# route table attachment in subnet assosiation
resource "aws_route_table_association" "subnetass" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.prod.id
  
}

# security group creation
resource "aws_security_group" "local" {
    vpc_id = aws_vpc.my-vpc.id
    tags = {
      Name = "my-sg"
    }
    ingress {
        description = "TLS FROM VPC"
        from_port = 22
        to_port = 22
        protocol = "TCP"
        cidr_blocks = [ "0.0.0.0/0" ]

    }

    ingress {
        description = "TLS FROM VPC"
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        description = "TLS FROM VPC"
        from_port = 443
        to_port = 443
        protocol = "TCP"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

  
}

# creating elastic ip
resource "aws_eip" "EIP" {
    domain = "vpc"
  
}

# creating nat gateway
resource "aws_nat_gateway" "my-nat" {
    allocation_id = aws_eip.EIP.allocation_id
    subnet_id = aws_subnet.public.id
    tags = {
      Name = "my-nat"
    }
  
}
# Creating Public EC2 Instance with Pulic IP address 
  resource "aws_instance" "anurag" {
    ami = var.ami
    instance_type = var.instance_type
    key_name = var.key_name
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [ aws_security_group.local.id ]
    associate_public_ip_address = true
    tags = {
      Name = "anurag"
    }
    
  }

  # creating route table for private ec2 and attach nat gateway
  resource "aws_route_table" "mypvt" {
    vpc_id = aws_vpc.my-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.my-nat.id
    }
    tags ={
    Name = "my-pvt"
    }
    
  }

  # private route table attachment in  subnet assosiation
  resource "aws_route_table_association" "my-assosiation" {
   subnet_id = aws_subnet.private.id
   route_table_id = aws_route_table.mypvt.id
    
  }

# Creating Private EC2 Instance without IP address 
resource "aws_instance" "my-pvt-ec2" {
    ami = var.ami
    instance_type = var.instance_type
    key_name = var.key_name
    subnet_id = aws_subnet.private.id
    vpc_security_group_ids = [ aws_security_group.local.id ]
    tags = {
      Name = "private-anurag"
    }
  
}


# for instance connection pub to private we can given the ip for pvt acess in root only not cd .ssh 


