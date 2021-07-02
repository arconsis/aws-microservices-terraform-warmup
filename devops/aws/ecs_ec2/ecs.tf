resource "aws_ecs_cluster" "main" {
  name               = var.project
  # add / remove ec2 instances when we do not have the 
  # desired capacity to put all the tasks
  capacity_providers = [aws_ecs_capacity_provider.capacity_provider.name] # https://iam-j.github.io/ecs/capacity-provider-for-scaling/ + https://kerneltalks.com/cloud-services/amazon-ecs-capacity-providers-overview/
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
      # type = "SRV"
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
      # type = "SRV"
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
      # type = "SRV"
      type = "A"
    }

    routing_policy = var.discovery_routing_policy
  }
}

resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = "capacity-provider-ecs-ec2"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ec2_ecs_asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 4
      minimum_scaling_step_size = 1
      status          = "ENABLED"
      target_capacity = 85
    }
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
  container_definitions    = data.template_file.books_api.rendered
  # network_mode             = "bridge"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
}

resource "aws_ecs_service" "service" {
  name            = var.books_api_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.books_api.arn
  desired_count   = var.books_api_desired_count
  launch_type     = "EC2"
  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.books_api_tg.arn
    container_name   = var.books_api_name
    container_port   = var.books_api_port
  }

  network_configuration {
    security_groups  = [aws_security_group.ec2_sg.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
  }

  service_registries {
    registry_arn      = aws_service_discovery_service.books_api_service_discovery.arn
    # container_name    = var.books_api_name # we need it because of bridge network mode
    # container_port    = var.books_api_port # we need it because of bridge network mode
  }

  # lifecycle {
  #   ignore_changes = [desired_count]
  # }
  depends_on  = [aws_alb_listener.http_listener]
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
  container_definitions    = data.template_file.users_api.rendered
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
}

################################################################################
# USERS API ECS Service
################################################################################
resource "aws_ecs_service" "users_api" {
  name            = var.users_api_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.users_api.arn
  desired_count   = var.users_api_desired_count
  launch_type     = "EC2"
  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }

  network_configuration {
    security_groups  = [aws_security_group.ec2_sg.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.users_api_tg.arn
    container_name   = var.users_api_name
    container_port   = var.users_api_port
  }

  service_registries {
    registry_arn      = aws_service_discovery_service.users_api_service_discovery.arn
    # container_name    = var.users_api_name # we need it because of bridge network mode
    # container_port    = var.users_api_port # we need it because of bridge network mode
  }

  # lifecycle {
  #   ignore_changes = [desired_count]
  # }
  depends_on  = [aws_alb_listener.http_listener]
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
  container_definitions    = data.template_file.recommendations_api.rendered
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
}

################################################################################
# RECOMMENDATION API ECS Service
################################################################################
resource "aws_ecs_service" "recommendations_api" {
  name            = var.recommendations_api_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.recommendations_api.arn
  desired_count   = var.recommendations_api_desired_count
  launch_type     = "EC2"
  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }

  network_configuration {
    security_groups  = [aws_security_group.private_ecs_ec2_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
  }

  # lifecycle {
  #   ignore_changes = [desired_count]
  # }

  service_registries {
    registry_arn      = aws_service_discovery_service.recommendations_api_service_discovery.arn
    # container_name    = var.recommendations_api_name # we need it because of bridge network mode
    # container_port    = var.recommendations_api_port # we need it because of bridge network mode
  }
}