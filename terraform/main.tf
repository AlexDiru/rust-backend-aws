provider "aws" {
  region = "us-east-2"
}

resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dev-vpc"
  }
}

resource "aws_subnet" "dev_subnet" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-2a"
  tags = {
    Name = "dev-subnet"
  }
}

resource "aws_security_group" "dev_sg" {
  vpc_id = aws_vpc.dev_vpc.id
  description = "Allow HTTP inbound traffic"
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "dev-sg"
  }
}

resource "aws_ecs_cluster" "devcluster" {
  name = "devcluster"
}

resource "aws_ecs_task_definition" "devcluster_task" {
  family                   = "my-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory = "512"

  container_definitions = jsonencode([
    {
      # name = "rust-backend"
      # image = "767397762342.dkr.ecr.us-east-2.amazonaws.com/my-ecr-repo:dcee113521737e6b805dfb411c3d606d7fbfa457"

      name      = "devcontainer"
      image     = "nginx" # Temporary for provisioning
      essential = true
      portMappings = [
        {
          name = "nginx-defaults"
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "devcluster_service" {
  name            = "devcluster-service"
  cluster         = aws_ecs_cluster.devcluster.id
  task_definition = aws_ecs_task_definition.devcluster_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.dev_subnet.id]
    security_groups  = [aws_security_group.dev_sg.id]
    assign_public_ip = true
  }
}