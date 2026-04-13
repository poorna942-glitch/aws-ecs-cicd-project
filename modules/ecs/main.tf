resource "aws_ecr_repository" "repo" {
  name         = "poorna-app-repo"
  force_delete = true
}

resource "aws_ecs_cluster" "cluster" {
  name = "poorna-cluster"
}

resource "aws_ecs_task_definition" "task" {
  family                   = "poorna-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::660830512243:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([{
    name      = "web-container"
    image     = "${aws_ecr_repository.repo.repository_url}:latest"
    essential = true
    portMappings = [{ containerPort = 80, hostPort = 80 }]
  }])
}

resource "aws_ecs_service" "svc" {
  name            = "poorna-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.sg_id]
    assign_public_ip = true
  }
}

variable "vpc_id" {}
variable "subnet_ids" { type = list(string) }
variable "sg_id" {}
