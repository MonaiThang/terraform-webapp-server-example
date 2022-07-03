# server
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.app_prefix
  public_key = tls_private_key.private_key.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename        = "${aws_key_pair.key_pair.key_name}.pem"
  content         = tls_private_key.private_key.private_key_pem
  file_permission = "0400"
}

resource "aws_security_group" "server_security_group" {
  name        = "${var.app_prefix}-server-sg"
  description = "Allow SSL inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Application port"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.remote_ip
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.app_prefix}-server-sg"
  }
}

resource "aws_instance" "webapp" {
  count         = 1
  ami           = var.ami
  instance_type = var.server_type

  key_name = aws_key_pair.key_pair.key_name

  subnet_id       = aws_subnet.subnet_public[count.index].id
  security_groups = [aws_security_group.server_security_group.id]

  associate_public_ip_address = true
  disable_api_termination     = true

  tags = {
    "cost-centre" = var.app_prefix
    Name          = var.app_prefix
  }
}

resource "aws_eip" "eip" {
  count = 1

  vpc = true

  instance                  = aws_instance.webapp[count.index].id
  associate_with_private_ip = aws_instance.webapp[count.index].private_ip
  depends_on                = [aws_internet_gateway.igw]

  tags = {
    "cost-centre" = var.app_prefix
    "Name"        = "${var.app_prefix}-${aws_instance.webapp[count.index].id}-eip"
  }
}