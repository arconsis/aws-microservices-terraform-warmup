################################################################################
# VPC Flows
################################################################################
# Provides a VPC/Subnet/ENI Flow Log to capture IP traffic for a specific network interface, 
# subnet, or VPC. Logs are sent to a CloudWatch Log Group or a S3 Bucket.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log
resource "aws_flow_log" "vpc_flow_logs" {
  iam_role_arn    = aws_iam_role.vpc_flow_cloudwatch_logs_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name = "vpc-flow-logs"
  retention_in_days = 30
}

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "books_api_log_group" {
  name              = "/ecs/books_api"
  retention_in_days = 30

  tags = {
    Name = "books_api_log_group"
  }
}

resource "aws_cloudwatch_log_stream" "books_api_log_stream" {
  name           = "books_api_log_stream"
  log_group_name = aws_cloudwatch_log_group.books_api_log_group.name
}

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "users_api_log_group" {
  name              = "/ecs/users_api"
  retention_in_days = 30

  tags = {
    Name = "users_api_log_group"
  }
}

resource "aws_cloudwatch_log_stream" "users_api_log_stream" {
  name           = "users_api_log_stream"
  log_group_name = aws_cloudwatch_log_group.users_api_log_group.name
}

resource "aws_cloudwatch_log_group" "recommendations_api_log_group" {
  name              = "/ecs/recommendations_api"
  retention_in_days = 30

  tags = {
    Name = "recommendations_api_log_group"
  }
}

resource "aws_cloudwatch_log_stream" "recommendations_api_log_stream" {
  name           = "recommendations_api_log_stream"
  log_group_name = aws_cloudwatch_log_group.recommendations_api_log_group.name
}
