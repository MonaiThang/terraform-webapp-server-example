# network - VPC and subnets
data "aws_availability_zones" "az" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr_prefix}.0.0.0/16"
  tags = {
    Name = var.app_prefix
  }
}

resource "aws_subnet" "subnet_public" {
  count             = length(data.aws_availability_zones.az.names)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "${var.cidr_prefix}.0.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.az.names[count.index]
  tags = {
    Name = "${var.app_prefix}-public-${data.aws_availability_zones.az.names[count.index]}"
  }
}

resource "aws_subnet" "subnet_private" {
  count             = length(data.aws_availability_zones.az.names)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "${var.cidr_prefix}.0.${count.index + 128}.0/24"
  availability_zone = data.aws_availability_zones.az.names[count.index]
  tags = {
    Name = "${var.app_prefix}-private-${data.aws_availability_zones.az.names[count.index]}"
  }
}

# internet gateway and routing tables
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.app_prefix}-igw"
  }
}

resource "aws_route_table" "route_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" = "p${var.app_prefix}-public"
  }
}

resource "aws_route_table" "route_private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.app_prefix}-private"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.subnet_public)
  subnet_id      = aws_subnet.subnet_public[count.index].id
  route_table_id = aws_route_table.route_public.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.subnet_private)
  subnet_id      = aws_subnet.subnet_private[count.index].id
  route_table_id = aws_route_table.route_private.id
}
