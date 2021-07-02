################################################################################
# ECS Cluster definition
################################################################################
resource "aws_ecs_cluster" "main" {
  name = "${var.project}_cluster"
}

resource "aws_service_discovery_private_dns_namespace" "segment" {
  name        = "discovery.com"
  description = "Service discovery for backends"
  vpc         = aws_vpc.main.id
}

resource "aws_service_discovery_service" "books_api_service_discovery" {
  name = "books_api"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.segment.id

    dns_records {
      ttl  = var.discovery_ttl
      type = "A"
    }

    routing_policy = var.discovery_routing_policy
  }
}

resource "aws_service_discovery_service" "users_api_service_discovery" {
  name = "users_api"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.segment.id

    dns_records {
      ttl  = var.discovery_ttl
      type = "A"
    }

    routing_policy = var.discovery_routing_policy
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "recommendations_api_service_discovery" {
  name = "recommendations_api"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.segment.id

    dns_records {
      ttl  = var.discovery_ttl
      type = "A"
    }

    routing_policy = var.discovery_routing_policy
  }
}

################################################################################
# BOOKS API ECS Tasks
################################################################################
data "template_file" "books_api" {
  template = file("../common/templates/ecs/service.json.tpl")
  vars = {
    service_name         = var.books_api_name
    image                = var.books_api_image
    container_port       = var.books_api_port
    host_port            = var.books_api_port
    fargate_cpu          = var.fargate_cpu
    fargate_memory       = var.fargate_memory
    aws_region           = var.aws_region
    aws_logs_group       = var.books_api_aws_logs_group
    network_mode         = var.network_mode
    service_enviroment   = jsonencode([])
  }
}

resource "aws_ecs_task_definition" "books_api" {
  family                   = var.books_api_task_family
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.books_api.rendered
}

################################################################################
# BOOKS API ECS Service
################################################################################
resource "aws_ecs_service" "books_api" {
  name            = var.books_api_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.books_api.arn
  desired_count   = var.books_api_desired_count
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.books_api_tg.id
    container_name   = var.books_api_name
    container_port   = var.books_api_port
  }

  service_registries {
    registry_arn = aws_service_discovery_service.books_api_service_discovery.arn
  }

  depends_on = [aws_alb_listener.main, aws_iam_role_policy_attachment.ecs_task_execution_role]
}

################################################################################
# USERS API ECS Tasks
################################################################################
data "template_file" "users_api" {
  template = file("../common/templates/ecs/service.json.tpl")

  vars = {
    service_name          = var.users_api_name
    image                 = var.users_api_image
    container_port        = var.users_api_port
    host_port             = var.users_api_port
    fargate_cpu           = var.fargate_cpu
    fargate_memory        = var.fargate_memory
    aws_region            = var.aws_region
    aws_logs_group        = var.users_api_aws_logs_group
    network_mode          = var.network_mode
    service_enviroment    = jsonencode([
      {
        "name": "RECOMMENDATIONS_SERVICE_URL",
        "value": "http://${aws_service_discovery_service.recommendations_api_service_discovery.name}.${aws_service_discovery_private_dns_namespace.segment.name}:${var.recommendations_api_port}"
      }
    ])
  }
}

resource "aws_ecs_task_definition" "users_api" {
  family                   = var.users_api_task_family
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.users_api.rendered
}

################################################################################
# USERS API ECS Service
################################################################################

resource "aws_ecs_service" "users_api" {
  name            = var.users_api_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.users_api.arn
  desired_count   = var.users_api_desired_count
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.users_api_tg.id
    container_name   = var.users_api_name
    container_port   = var.users_api_port
  }

  service_registries {
    registry_arn     = aws_service_discovery_service.users_api_service_discovery.arn
  }

  depends_on = [aws_alb_listener.main, aws_iam_role_policy_attachment.ecs_task_execution_role]
}

################################################################################
# RECOMMENDATION API ECS Tasks
################################################################################
data "template_file" "recommendations_api" {
  template = file("../common/templates/ecs/service.json.tpl")
  vars = {
    service_name         = var.recommendations_api_name
    image                = var.recommendations_api_image
    container_port       = var.recommendations_api_port
    host_port            = var.recommendations_api_port
    fargate_cpu          = var.fargate_cpu
    fargate_memory       = var.fargate_memory
    aws_region           = var.aws_region
    aws_logs_group       = var.recommendations_api_aws_logs_group
    network_mode         = var.network_mode
    service_enviroment   = jsonencode([])
  }
}

resource "aws_ecs_task_definition" "recommendations_api" {
  family                   = var.recommendations_api_task_family
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.recommendations_api.rendered
}

################################################################################
# RECOMMENDATION API ECS Service
################################################################################
resource "aws_ecs_service" "recommendations_api" {
  name            = var.recommendations_api_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.recommendations_api.arn
  desired_count   = var.recommendations_api_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.private_ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
  }

  service_registries {
    registry_arn     = aws_service_discovery_service.recommendations_api_service_discovery.arn
  }

  depends_on = [aws_alb_listener.main, aws_iam_role_policy_attachment.ecs_task_execution_role]
}
