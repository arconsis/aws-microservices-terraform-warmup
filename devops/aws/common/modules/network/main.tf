################################################################################
# VPC Definition
################################################################################
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge({
    Name = "aws-warmup-vpc"
  }, var.default_tags)
}

################################################################################
# IG Definition
################################################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = merge({
    Name = "aws-warmup-ig"
  }, var.default_tags)
}

################################################################################
# Subnets Definition
################################################################################

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.this.id
  availability_zone = element(var.public_subnets, count.index)

  cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 4, count.index)

  tags = merge({
    Name   = "aws-warmup-public-subnet"
    Role   = "public"
    VPC    = aws_vpc.this.id
    Subnet = element(var.public_subnets, count.index)
  }, var.default_tags)
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  availability_zone = element(var.private_subnets, count.index)

  cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 4, count.index + length(var.public_subnets))

  tags = merge({
    Name   = "aws-warmup-public-subnet"
    Role   = "private"
    VPC    = aws_vpc.this.id
    Subnet = element(var.private_subnets, count.index)
  }, var.default_tags)
}

################################################################################
# NAT Definition
################################################################################

# Create a NAT gateway with an Elastic IP for each private subnet to get internet connectivity
resource "aws_eip" "nat" {
  count = length(var.private_subnets)

  vpc = true

  tags = merge({
    Name   = "aws-warmup-eip"
    Role   = "private"
    VPC    = aws_vpc.this.id
    Subnet = element(var.private_subnets, count.index)
  }, var.default_tags)

}

resource "aws_nat_gateway" "ngw" {
  count = length(var.private_subnets)

  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = merge({
    Name   = "aws-warmup-ngw"
    Role   = "private"
    VPC    = aws_vpc.this.id
    Subnet = element(aws_subnet.public.*.id, count.index)
  }, var.default_tags)
}

################################################################################
# Route Tables, Routes and Associations
################################################################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge({
    Name   = "aws-warmup-public-rt"
    Role   = "public"
    VPC    = aws_vpc.this.id
  }, var.default_tags)
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.this.id

  tags = merge({
    Name   = "aws-warmup-private-rt"
    Role   = "private"
    VPC    = aws_vpc.this.id
    Subnet = element(aws_subnet.private.*.id, count.index)
  }, var.default_tags)
}

resource "aws_route" "private" {
  count                  = length(var.private_subnets)
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.ngw.*.id, count.index)
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}
