################################################################################
# VPC Definition
################################################################################
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name        = "aws-warmup-${var.environment}-vpc"
    Project     = "aws-warmup"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

################################################################################
# IG Definition
################################################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = {
    Name        = "${var.project}_${var.environment}_ig"
    Environment = var.environment
  }
}

################################################################################
# Subnets Definition
################################################################################

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.this.id
  availability_zone = element(var.public_subnets, count.index)

  cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 4, count.index)

  tags = {
    Name        = "aws-warmup-${var.environment}-public-subnet"
    Project     = "aws-warmup"
    Role        = "public"
    Environment = var.environment
    ManagedBy   = "terraform"
    Subnet      = element(var.public_subnets, count.index)
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  availability_zone = element(var.private_subnets, count.index)

  cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 4, count.index + length(var.public_subnets))

  tags = {
    Name        = "aws-warmup-${var.environment}-private-subnet"
    Project     = "aws-warmup"
    Role        = "private"
    Environment = var.environment
    ManagedBy   = "terraform"
    Subnet      = element(var.private_subnets, count.index)
  }
}

################################################################################
# NAT Definition
################################################################################

# Create a NAT gateway with an Elastic IP for each private subnet to get internet connectivity
resource "aws_eip" "nat" {
  count = length(var.private_subnets)

  vpc = true

  tags = {
    Name        = "aws-warmup-${var.environment}-eip"
    Project     = "aws-warmup"
    Environment = var.environment
    VPC         = aws_vpc.this.id
    ManagedBy   = "terraform"
    Role        = "private"
  }
}

resource "aws_nat_gateway" "ngw" {
  count = length(var.private_subnets)

  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  #  depends_on    = [aws_internet_gateway.main]

  tags = {
    Name        = "aws-warmup-${var.environment}-ngw"
    Project     = "aws-warmup"
    Environment = var.environment
    VPC         = aws_vpc.this.id
    ManagedBy   = "terraform"
    Role        = "private"
    Subnet      = element(aws_subnet.public.*.id, count.index)
  }
}

################################################################################
# Route Tables, Routes and Associations
################################################################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "aws-warmup-${var.environment}-public-rt"
    Environment = var.environment
    Project     = "aws-warmup"
    Role        = "public"
    VPC         = aws_vpc.this.id
    ManagedBy   = "terraform"
  }
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

resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "aws-warmup-${var.environment}-private-rt"
    Environment = var.environment
    Project     = "aws-warmup"
    Role        = "public"
    VPC         = aws_vpc.this.id
    Subnet      = element(aws_subnet.private.*.id, count.index)
    ManagedBy   = "terraform"
  }
}

# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
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
