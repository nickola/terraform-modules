resource "aws_vpc" "network" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = "${var.name}-network"
  }
}

# Public subnets
resource "aws_subnet" "public_subnets" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.network.id
  cidr_block              = each.value.cidr
  availability_zone       = each.key
  map_public_ip_on_launch = try(each.value.map_public_ip_on_launch, false)

  tags = {
    Name = "${var.name}-public-subnet-${each.key}"
  }
}

# Internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  count  = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.network.id

  tags = {
    Name = "${var.name}-internet-gateway"
  }
}

resource "aws_route_table" "internet_gateway_route_table" {
  count  = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.network.id

  tags = {
    Name = "${var.name}-internet-gateway-route-table"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway[0].id
  }
}

resource "aws_route_table_association" "internet_gateway_route_table_association" {
  for_each = aws_subnet.public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.internet_gateway_route_table[0].id
}

# Private subnets
resource "aws_subnet" "private_subnets" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.network.id
  cidr_block        = each.value.cidr
  availability_zone = each.key

  tags = {
    Name = "${var.name}-private-subnet-${each.key}"
  }
}

# Elastic IP for NAT gateway
resource "aws_eip" "nat_elastic_ip" {
  for_each = (length(var.public_subnets) > 0 && length(var.private_subnets) > 0) ? aws_subnet.public_subnets : {}
  domain   = "vpc"
}

# NAT gateway
resource "aws_nat_gateway" "nat_gateway" {
  for_each = (length(var.public_subnets) > 0 && length(var.private_subnets) > 0) ? aws_subnet.public_subnets : {}

  allocation_id = aws_eip.nat_elastic_ip[each.key].id
  subnet_id     = each.value.id

  tags = {
    Name = "${var.name}-nat-gateway-${each.key}"
  }
}

resource "aws_route_table" "nat_gateway_route_table" {
  for_each = (length(var.public_subnets) > 0 && length(var.private_subnets) > 0) ? aws_subnet.public_subnets : {}
  vpc_id   = aws_vpc.network.id

  tags = {
    Name = "${var.name}-nat-gateway-route-table-${each.key}"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway[each.key].id
  }
}

resource "aws_route_table_association" "nat_gateway_route_table_association" {
  for_each = (length(var.public_subnets) > 0 && length(var.private_subnets) > 0) ? aws_subnet.private_subnets : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.nat_gateway_route_table[each.key].id
}

# Outputs
output "vpc" {
  value = aws_vpc.network
}

output "public_subnets" {
  value = aws_subnet.public_subnets
}

output "private_subnets" {
  value = aws_subnet.private_subnets
}
