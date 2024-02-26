######################defining provider#####################
provider "aws" {
  region = "us-east-2"
  access_key = ""
  secret_key = ""
}
###################custom vpc creation####################
resource "aws_vpc" "custom-vpc" {

        cidr_block = "10.10.0.0/16"
        tags = {
                Name = "custom-vpc"
        }
}
################subnets creation############################
resource "aws_subnet" "subnet-1" {
        vpc_id = "${aws_vpc.custom-vpc.id}"
        cidr_block = "10.10.1.0/24"
        availability_zone = "us-east-2a"
        tags = {
                Name = "subnet-1"
        }
}
resource "aws_subnet" "subnet-2" {
        vpc_id = "${aws_vpc.custom-vpc.id}"
        cidr_block = "10.10.2.0/24"
        availability_zone = "us-east-2b"
        tags = {
                Name = "subnet-2"
        }
}
#######################internate gateway creation#####################
resource "aws_internet_gateway" "custom-vpc-igw" {

        vpc_id = "${aws_vpc.custom-vpc.id}"
        tags = {
                Name = "custom-vpc-igw"
        }
}
####################route table creation#####################
resource "aws_route_table" "public-rt" {
        vpc_id = "${aws_vpc.custom-vpc.id}"

        route {
                cidr_block = "0.0.0.0/0"
                gateway_id = "${aws_internet_gateway.custom-vpc-igw.id}"
        }
        route {
                cidr_block = "172.31.0.0/20"
                vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peering.id}"
        }
                tags = {
                                Name = "custom-vpc-route-table"
                }
}
#####################route table association#########################
resource "aws_route_table_association" "public-routing-1" {

        subnet_id = "${aws_subnet.subnet-1.id}"
        route_table_id = "${aws_route_table.public-rt.id}"
}
####################security group creation######################
resource "aws_security_group" "web_sg" {
  name        = "web-security-group"
  description = "Allow traffic on ports 80 and 8080"
  vpc_id      = "${aws_vpc.custom-vpc.id}"
  tags = {
        Name = "custom-sg"
  }


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust the CIDR block as needed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
########################Linux server creation######################
resource "aws_instance" "test" {

        ami = "ami-0cf7b2f456cd5efd4"
        instance_type = "t2.micro"
        tags = {

                Name = "machine_created_by_terraform"
        }
        subnet_id = "${aws_subnet.subnet-1.id}"
        key_name = "ohio_key_pair"
        associate_public_ip_address = true
        vpc_security_group_ids = [aws_security_group.web_sg.id]
}

