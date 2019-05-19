// VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"

  tags {
    Name        = "${var.name}-vpc"
    Team        = "${var.team}"
    Environment = "${var.environment}"
    Service     = "${var.service}"
    Product     = "${var.product}"
    Owner       = "${var.owner}"
    Description = "${var.description}"
    managed_by  = "terraform"
  }
}

// Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name        = "${var.name}-igw"
    Team        = "${var.team}"
    Environment = "${var.environment}"
    Service     = "${var.service}"
    Product     = "${var.product}"
    Owner       = "${var.owner}"
    Description = "${var.description}"
    managed_by  = "terraform"
  }
}

// Public subnet/s
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${element(split(",", var.public_subnets), count.index)}"
  availability_zone       = "${element(split(",", var.azs), count.index)}"
  count                   = "${length(split(",", var.public_subnets))}"
  map_public_ip_on_launch = true

  tags {
    Name        = "${var.name}-public-${element(split(",", var.azs), count.index)}"
    Team        = "${var.team}"
    Environment = "${var.environment}"
    Service     = "${var.service}"
    Product     = "${var.product}"
    Owner       = "${var.owner}"
    Description = "${var.description}"
    managed_by  = "terraform"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name        = "${var.name}-public"
    Team        = "${var.team}"
    Environment = "${var.environment}"
    Service     = "${var.service}"
    Product     = "${var.product}"
    Owner       = "${var.owner}"
    Description = "${var.description}"
    managed_by  = "terraform"
  }
}

resource "aws_route" "default" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(compact(split(",", var.public_subnets)))}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

// Private subnet/s
resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(split(",", var.private_subnets), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
  count             = "${length(split(",", var.private_subnets))}"

  tags {
    Name        = "${var.name}-private-${element(split(",", var.azs), count.index)}"
    Team        = "${var.team}"
    Environment = "${var.environment}"
    Service     = "${var.service}"
    Product     = "${var.product}"
    Owner       = "${var.owner}"
    Description = "${var.description}"
    managed_by  = "terraform"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  count  = "${length(split(",", var.private_subnets))}"

  tags {
    Name        = "${var.name}-private-${element(split(",", var.azs), count.index)}"
    Team        = "${var.team}"
    Environment = "${var.environment}"
    Service     = "${var.service}"
    Product     = "${var.product}"
    Owner       = "${var.owner}"
    Description = "${var.description}"
    managed_by  = "terraform"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  count          = "${length(split(",", var.private_subnets))}"
}

// NAT gateway
resource "aws_eip" "nat" {
  count = "${var.nat_gateways_count}"
  vpc   = true
}

resource "aws_route" "nat_gateway" {
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.nat.*.id, count.index)}"
  count                  = "${length(split(",", var.private_subnets)) * signum(var.nat_gateways_count)}"
  depends_on             = ["aws_route_table.private"]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  count         = "${var.nat_gateways_count}"
}

/* DB Subnet Group that can be used by RDS instance on private subnet space
resource "aws_db_subnet_group" "rds_db_subnet_group" {
  name        = "${var.name}-${var.team}-${var.environment}-${var.product}"
  description = "DB subnet group used by RDS"
  subnet_ids  = ["${aws_subnet.private.*.id}"]

  tags {
    Team        = "${var.team}"
    Environment = "${var.environment}"
    Service     = "${var.service}"
    Product     = "${var.product}"
    Owner       = "${var.owner}"
    managed_by  = "terraform"
  }
} */

// S3 VPC endpoint
resource "aws_vpc_endpoint" "private-s3" {
  count           = "${var.s3_endpoint_enabled}"
  vpc_id          = "${aws_vpc.vpc.id}"
  service_name    = "com.amazonaws.${var.region}.s3"
  route_table_ids = ["${aws_route_table.public.id}", "${aws_route_table.private.*.id}"]
}

// DynamoDB VPC endpoint
resource "aws_vpc_endpoint" "private-dynamodb" {
  count           = "${var.dynamodb_endpoint_enabled}"
  vpc_id          = "${aws_vpc.vpc.id}"
  service_name    = "com.amazonaws.${var.region}.dynamodb"
  route_table_ids = ["${aws_route_table.public.id}", "${aws_route_table.private.*.id}"]
}
