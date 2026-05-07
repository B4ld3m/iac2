# VPC 

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames  = true

  tags = { Name = "${local.prefix}-vpc" }
}

# Internet Gateway 

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${local.prefix}-igw" }
}

# Public Subnets (AZ-a, AZ-b)

resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = local.availability_zones[count.index]

  map_public_ip_on_launch = true
  tags = { Name = "${local.prefix}-public-${count.index == 0 ? "a" : "b"}" }
}

# Private Subnets (AZ-a, AZ-b)

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.availability_zones[count.index]

  tags = { Name = "${local.prefix}-private-${count.index == 0 ? "a" : "b"}" }
}

# Elastic IPs para NAT Gateways

resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"
  tags   = { Name = "${local.prefix}-eip-nat-${count.index == 0 ? "a" : "b"}" }
}

# NAT Gateways

resource "aws_nat_gateway" "nat" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags       = { Name = "${local.prefix}-nat-${count.index == 0 ? "a" : "b"}" }
  depends_on = [aws_internet_gateway.igw]
}

# Public Route Table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "${local.prefix}-rt-public" }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Tables

resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = { Name = "${local.prefix}-rt-private-${count.index == 0 ? "a" : "b"}" }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}