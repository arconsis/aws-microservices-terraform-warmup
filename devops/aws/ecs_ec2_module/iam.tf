################################################################################
# ECS Tasks Execution IAM
################################################################################
# ECS task execution role data
data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid = ""
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

# ECS task execution role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

################################################################################
# VPC Flow Logs IAM
################################################################################
resource "aws_iam_role" "vpc_flow_cloudwatch_logs_role" {
  name               = "vpc-flow-cloudwatch-logs-role"
  assume_role_policy = file("../common/templates/policies/vpc_flow_cloudwatch_logs_role.json.tpl")
}

resource "aws_iam_role_policy" "vpc_flow_cloudwatch_logs_policy" {
  name = "vpc-flow-cloudwatch-logs-policy"
  role = aws_iam_role.vpc_flow_cloudwatch_logs_role.id
  policy = file("../common/templates/policies/vpc_flow_cloudwatch_logs_policy.json.tpl")
}

################################################################################
# ECS
################################################################################
resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs-instance-role-service"
  path = "/"
  assume_role_policy = file("../common/templates/policies/ecs_instance_role.json.tpl")
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_attachment" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_service_role" {
  role = aws_iam_role.ecs_instance_role.name
}
