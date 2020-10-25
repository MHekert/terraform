resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = element(var.azs, 0)
  map_public_ip_on_launch = true

}

resource "aws_subnet" "secondary" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = element(var.azs, 1)
  map_public_ip_on_launch = true

}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
}
