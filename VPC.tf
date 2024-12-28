provider "aws" {
  region = "us-east-1" # Specify your desired region
}

# VPC
resource "aws_vpc" "captaintacticus" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "captaintacticus"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.captaintacticus.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a" # Adjust as needed
  map_public_ip_on_launch = true
  tags = {
    Name = "captaintacticus-public-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.captaintacticus.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b" # Adjust as needed
  map_public_ip_on_launch = true
  tags = {
    Name = "captaintacticus-public-2"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.captaintacticus.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a" # Adjust as needed
  tags = {
    Name = "captaintacticus-private-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.captaintacticus.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b" # Adjust as needed
  tags = {
    Name = "captaintacticus-private-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.captaintacticus.id
  tags = {
    Name = "captaintacticus-igw"
  }
}

# NAT Gateway (Requires Elastic IP)
resource "aws_eip" "nat_eip" {
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "captaintacticus-nat"
  }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.captaintacticus.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "captaintacticus-public-rt"
  }
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.captaintacticus.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "captaintacticus-private-rt"
  }
}

# Route Table Associations for Public Subnets
resource "aws_route_table_association" "public_rt_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# Route Table Associations for Private Subnets
resource "aws_route_table_association" "private_rt_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}
