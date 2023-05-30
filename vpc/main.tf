resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public" {
  count      = length(var.public_subnet_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.public_subnet_cidr_block, count.index)
  # availability_zone = var.public_subnet_az

  tags = {
    Name = "Public subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr_block)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidr_block, count.index)
  availability_zone = element(var.az, count.index)

  tags = {
    Name = "Private subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "access_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "Access route table"
  }
}

resource "aws_route_table_association" "public_subnet_asso" {
  count          = length(var.public_subnet_cidr_block)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.access_rt.id
}

