provider "aws" {
  region     = "${var.aws_default_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

resource "aws_key_pair" "monitor" {
  key_name   = "${var.aws_tag}"
  public_key = "${file("id_rsa.pub")}"
}

resource "aws_vpc" "monitor" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.aws_tag}"
  }
}

resource "aws_internet_gateway" "monitor" {
  vpc_id = "${aws_vpc.monitor.id}"

  tags {
    Name = "${var.aws_tag}"
  }
}

resource "aws_subnet" "monitor" {
  vpc_id                  = "${aws_vpc.monitor.id}"
  cidr_block              = "192.168.92.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_default_region}c"

  tags {
    Name = "${var.aws_tag}"
  }
}

resource "aws_route_table" "monitor" {
  vpc_id = "${aws_vpc.monitor.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.monitor.id}"
  }

  tags {
    Name = "${var.aws_tag}"
  }
}

resource "aws_main_route_table_association" "monitor" {
  vpc_id         = "${aws_vpc.monitor.id}"
  route_table_id = "${aws_route_table.monitor.id}"
}

resource "aws_network_acl" "monitor" {
  vpc_id     = "${aws_vpc.monitor.id}"
  subnet_ids = ["${aws_subnet.monitor.id}"]

  ingress {
    rule_no    = 100
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }

  tags {
    Name = "${var.aws_tag}"
  }
}

resource "aws_security_group" "monitor-ssh" {
  vpc_id      = "${aws_vpc.monitor.id}"
  name        = "${var.aws_tag}-ssh"
  description = "allow external ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.aws_tag}-ssh"
  }
}

resource "aws_security_group" "monitor-http" {
  vpc_id      = "${aws_vpc.monitor.id}"
  name        = "${var.aws_tag}-http"
  description = "allow external http/https"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.aws_tag}-http"
  }
}

resource "aws_security_group" "monitor-icmp" {
  vpc_id      = "${aws_vpc.monitor.id}"
  name        = "${var.aws_tag}-icmp"
  description = "allow icmp"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 8
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 8
    to_port     = 8
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.aws_tag}-icmp"
  }
}

resource "aws_security_group" "monitor-internal" {
  vpc_id      = "${aws_vpc.monitor.id}"
  name        = "${var.aws_tag}-internal"
  description = "allow all VPC internal traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_subnet.monitor.cidr_block}"]
  }

  # allow all output traffic from the VPC
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.aws_tag}-internal"
  }
}

resource "aws_instance" "status" {
  ami           = "${var.status_ami}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.monitor.id}"

  user_data = <<EOF
#cloud-config
hostname: ${var.status_hostname}.${var.domain_name}
fqdn: ${var.status_hostname}.${var.domain_name}
EOF

  instance_initiated_shutdown_behavior = "stop"

  vpc_security_group_ids = [
    "${aws_security_group.monitor-internal.id}",
    "${aws_security_group.monitor-icmp.id}",
    "${aws_security_group.monitor-ssh.id}",
    "${aws_security_group.monitor-http.id}",
  ]

  key_name = "${aws_key_pair.monitor.id}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = false
  }

  tags {
    Name = "${var.aws_tag}"
  }
}

resource "aws_eip" "status" {
  vpc      = true
  instance = "${aws_instance.status.id}"
}

resource "aws_route53_record" "status" {
  zone_id = "${var.aws_zone_id}"
  name    = "${var.status_hostname}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.status.public_ip}"]
}
