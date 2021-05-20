resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true


  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-vpc" })
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-igw" })
  )
}

resource "aws_subnet" "main" {
  for_each = var.az

  vpc_id = aws_vpc.main.id

  cidr_block              = "10.0.${each.value}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_region.current.name}${each.key}"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public" })
  )
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public" })
  )
}

resource "aws_route_table_association" "main" {
  for_each = var.az

  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.main.id
}