resource "aws_vpc" "main" {

 cidr_block           = var.vpc_cidr

 enable_dns_hostnames = true

 tags = {

   name = "main"

 }

}


resource "aws_subnet" "subnet" {

 vpc_id                  = aws_vpc.main.id

 cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 1)

 map_public_ip_on_launch = true

 availability_zone       = "us-west-2a"

}



resource "aws_subnet" "subnet2" {

 vpc_id                  = aws_vpc.main.id

 cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 2)

 map_public_ip_on_launch = true

 availability_zone       = "us-west-2b"

}

resource "aws_subnet" "subnet3" {

 vpc_id                  = aws_vpc.main.id

 cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 3)

 map_public_ip_on_launch = true

 availability_zone       = "us-west-2c"

}

resource "aws_subnet" "subnet4" {

 vpc_id                  = aws_vpc.main.id

 cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 4)

 map_public_ip_on_launch = true

 availability_zone       = "us-west-2b"

}




resource "aws_security_group" "security_group" {

 name   = "ecs-security-group"

 vpc_id = aws_vpc.main.id



 ingress {

   from_port   = 0

   to_port     = 0

   protocol    = -1

   self        = "false"

   cidr_blocks = ["0.0.0.0/0"]

   description = "any"

 }



 egress {

   from_port   = 0

   to_port     = 0

   protocol    = "-1"

   cidr_blocks = ["0.0.0.0/0"]

 }

}

resource "aws_internet_gateway" "internet_gateway" {

 vpc_id = aws_vpc.main.id

 tags = {

   Name = "internet_gateway"

 }

}

resource "aws_route_table" "route_table" {

 vpc_id = aws_vpc.main.id

 route {

   cidr_block = "0.0.0.0/0"

   gateway_id = aws_internet_gateway.internet_gateway.id

 }

}



resource "aws_route_table_association" "subnet_route" {

 subnet_id      = aws_subnet.subnet3.id

 route_table_id = aws_route_table.route_table.id

}

resource "aws_route_table_association" "subnet_route2" {

 subnet_id      = aws_subnet.subnet4.id

 route_table_id = aws_route_table.route_table.id

}


resource "aws_eip" "Nat-Gateway-EIP" {
  depends_on = [
    aws_route_table_association.subnet_route
  ]
  vpc = true
}

resource "aws_nat_gateway" "ECS-nat" {
  allocation_id = aws_eip.Nat-Gateway-EIP.id
  subnet_id     = aws_subnet.subnet3.id

  depends_on = [
    aws_eip.Nat-Gateway-EIP
  ]

}

resource "aws_route_table" "NAT-Gateway-RT" {
  depends_on = [
    aws_nat_gateway.ECS-nat
  ]

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ECS-nat.id
  }

  tags = {
    Name = "Route Table for NAT Gateway"
  }

}

resource "aws_route_table_association" "Nat-Gateway-RT-Association-subnet" {
  depends_on = [
    aws_route_table.NAT-Gateway-RT
  ]

  subnet_id      = aws_subnet.subnet.id

  route_table_id = aws_route_table.NAT-Gateway-RT.id
}

resource "aws_route_table_association" "Nat-Gateway-RT-Association-subnet2" {
  depends_on = [
    aws_route_table.NAT-Gateway-RT
  ]

  subnet_id      = aws_subnet.subnet2.id

  route_table_id = aws_route_table.NAT-Gateway-RT.id
}

output "subnet" {
  value = aws_subnet.subnet
}

output "subnet2" {
  value = aws_subnet.subnet2
}

output "subnet3" {
  value = aws_subnet.subnet3
}

output "subnet4" {
  value = aws_subnet.subnet4
}

output "security_group" {
  value = aws_security_group.security_group
}

output "main" {
  value = aws_vpc.main
}
