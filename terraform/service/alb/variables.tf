variable "alb_name" {
  description = "The name of the ALB."
  type        = string
}

variable "target_group_name" {
  description = "The name of the Lambda target group."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the ALB and its security group"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB."
  type        = list(string)
}

variable "lambda_function_name" {
  description = "The name of the Lambda function to allow ALB to invoke"
  type        = string
}

variable "lambda_function_arn" {
  description = "The ARN of the Lambda function to allow ALB to invoke"
  type        = string
}
