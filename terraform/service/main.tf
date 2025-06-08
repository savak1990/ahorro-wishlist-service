locals {
  lambda_dbstream_handler_name        = "${var.base_name}-dbstream-lambda"
  alb_name                            = "${var.base_name}-alb"
  target_group_name                   = "${var.base_name}-tg"
  lambda_app_handler_name             = "${var.base_name}-app-handler"
  dynamodb_service_access_policy_name = "${var.base_name}-db-access-policy"
}

resource "aws_lb" "this" {
  name               = local.alb_name
  internal           = false
  load_balancer_type = "application"
  subnets            = var.alb_subnet_ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "lambda" {
  name        = local.target_group_name
  target_type = "lambda"

  health_check {
    enabled             = true
    path                = "/health"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  depends_on = [aws_cloudwatch_log_group.lambda_log_group]
}

resource "aws_lambda_permission" "alb" {
  statement_id  = "AllowExecutionFromALB"
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_app_handler_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.lambda.arn
}

resource "aws_lb_target_group_attachment" "lambda" {
  target_group_arn = aws_lb_target_group.lambda.arn
  target_id        = aws_lambda_function.lambda.arn
  depends_on       = [aws_lambda_permission.alb]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lambda.arn
  }
}

resource "aws_security_group" "alb" {
  name        = "${local.alb_name}-sg"
  description = "Security group for ALB ${local.alb_name}"
  vpc_id      = var.alb_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 14
}

resource "aws_lambda_function" "lambda" {
  function_name    = local.lambda_app_handler_name
  role             = var.app_lambda_role_arn
  handler          = "bootstrap"
  runtime          = "provided.al2"
  filename         = var.app_handler_zip
  source_code_hash = filebase64sha256(var.app_handler_zip)

  environment {
    variables = {
      DYNAMODB_TABLE = var.db_table_name
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0"
}
