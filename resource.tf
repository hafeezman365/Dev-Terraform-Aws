resource "aws_vpc" "festival_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "festival_subnet" {
  vpc_id                  = aws_vpc.festival_vpc.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, 1)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "dev_subnet"
  }
}

resource "aws_internet_gateway" "festival_igw" {
  vpc_id = aws_vpc.festival_vpc.id

  tags = {
    Name = "dev_igw"
  }
}

resource "aws_route_table" "festival_rt" {
  vpc_id = aws_vpc.festival_vpc.id

  tags = {
    Name = "dev_rt"
  }
}

resource "aws_route" "festival_r" {
  route_table_id         = aws_route_table.festival_rt.id
  destination_cidr_block = var.destination_cidr_block
  gateway_id             = aws_internet_gateway.festival_igw.id
}

resource "aws_route_table_association" "festival_rta" {
  subnet_id      = aws_subnet.festival_subnet.id
  route_table_id = aws_route_table.festival_rt.id
}

resource "aws_security_group" "festival_sg" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.festival_vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.destination_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.destination_cidr_block]
  }
}





resource "aws_key_pair" "festival_auth" {
  key_name = "festivalkey"
  public_key = file("~/.ssh/festivalkey.pub")
}



resource "aws_instance" "dev_node" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.festival_ami.id
  key_name               = aws_key_pair.festival_auth.id
  vpc_security_group_ids = [aws_security_group.festival_sg.id]
  subnet_id              = aws_subnet.festival_subnet.id
  user_data = templatefile("userdata.tpl", {})

  root_block_device {
    volume_size = 10
  }

  tags = {
    "Name" = "dev-node"
  }
}