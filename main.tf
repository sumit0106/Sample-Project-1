resource "aws_instance" "project" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.available_ami.id
  tags = {
    name = "Project-EC2"
  }
}

resource "aws_vpc" "projectVPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name = "Project-vpc"
  }
}

resource "aws_internet_gateway" "project-igw" {
  vpc_id = aws_vpc.projectVPC.id
}

resource "aws_subnet" "project-public-Subnet" {
  vpc_id = aws_vpc.projectVPC.id
  cidr_block = var.public-subnet
  availability_zone = "ap-south-1a"
  tags = {
    name = "Public-Subnet"
  }
}

resource "aws_subnet" "project-private-Subnet" {
  vpc_id = aws_vpc.projectVPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    name = "Private-Subnet"
  }
}

# resource "aws_subnet" "projectSubnetAZ"{
#     vpc_id = aws_vpc.projectVPC.id
#     cidr_block = "10.0.2.0/24"
#     availability_zone = "ap-south-1c"
#     tags = {
#         Name = "ProjectAZ-Subnet"
#     }
# }

resource "aws_db_instance" "project-rds" {
  username = "admin"
  password = "admin1234"
  allocated_storage = 20
  db_name = "projectdb1"
  engine = "mysql"
  instance_class = "db.t3.medium"
  skip_final_snapshot = true
}

resource "aws_security_group" "project-SG" {
  name        = "app-security-group"
  description = "Allow inbound HTTP traffic for the application"
  vpc_id      = aws_vpc.projectVPC.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "app-security-group" {
  name        = "app-security-group1"
  description = "Allow inbound HTTP traffic for the application"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "project-elb" {
  name               = "Project-ELB"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.project-SG.id]
  subnets            = [
    aws_subnet.project-public-Subnet.id,
    aws_subnet.project-private-Subnet.id
  ]
  tags = {
    name = "Project-ELB"
  }
}

resource "aws_launch_template" "app_launch_template" {
  name = "app-launch-template"
  image_id = data.aws_ami.available_ami.id
  instance_type = "t2.micro" 
  security_group_names = [aws_security_group.project-SG.name]
}

resource "aws_launch_template" "project-launch_template" {
  name_prefix   = "Project"
  image_id      = data.aws_ami.available_ami.id
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "Project-AutoScaling" {
  availability_zones = ["ap-south-1a"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.project-launch_template.id
    version = "$Latest"
  }
}

