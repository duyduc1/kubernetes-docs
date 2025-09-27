variable "region" {
  description = "Region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "ami_id"
  type        = string
  default     = "ami-0360c520857e3138f"
}

variable "instance_type" {
  description = "instance_type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "key_name"
  type        = string
  default     = "testing_ssh"
}

variable "vpc_security_group_ids" {
  description = "List of vpc_security_group_ids"
  type        = list(string)
  default     = ["sg-0970485b8f8979daa"]
}

variable "subnet_ids" {
  description = "subnet_ids"
  type        = list(string)
  default     = ["subnet-06d05fea9a4308d4d","subnet-05a027f0c03029951"]
}

variable "asg_name" {
  description = "asg_name"
  type        = string
  default     = "asg-memory-scaling"
}

variable "launch_template_name" {
  description = "launch_template_name"
  type        = string
  default     = "lt-memory-cwagent"
}

variable "metrics_namespace" {
  description = "metrics_namespace"
  type        = string
  default     = "CustomMetrics"
}

variable "min_size" {
  description = "min_size"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "max_size"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "desired_capacity"
  type        = number
  default     = 1
}

variable "scale_policy_cooldown" {
  description = "Cooldown period after scaling before allowing the next action"
  type        = number
  default     = 300
}

variable "scale_out_policy_adjustment" {
  description = "Number of instances added when performing scale out"
  type        = number
  default     = 1
}

variable "scale_in_policy_adjustment" {
  description = "Number of instances removed when performing scale in"
  type        = number
  default     = -1
}

variable "memory_high_scale_out_threshold" {
  description = "Memory threshold to trigger scale-out"
  type        = number
  default     = 80
}

variable "memory_high_scale_out_period" {
  description = "Period (in seconds) to evaluate memory usage for scale-out"
  type        = number
  default     = 60  
}

variable "memory_high_scale_out_evaluation_periods" {
  description = "Number of periods memory must exceed threshold to trigger scale-out"
  type        = number
  default     = 3
}

variable "memory_low_scale_in_threshold" {
  description = "Memory threshold to trigger scale-in"
  type        = number
  default     = 50
}

variable "memory_low_scale_in_period" {
  description = "Period (in seconds) to evaluate memory usage for scale-in"
  type        = number
  default     = 300  
}

variable "memory_low_scale_in_evaluation_periods" {
  description = "Number of periods memory must stay below threshold to trigger scale-in"
  type        = number
  default     = 3  
}

variable "response_time_high_scale_out_threshold" {
  description = "Reponse time threshold to trigger scale-out"
  type        = number
  default     = 0.5
}

variable "response_time_high_scale_out_period" {
  description = "Period (in seconds) to evaluate response time usage for scale-out"
  type        = number
  default     = 60  
}

variable "response_time_high_scale_out_evaluation_periods" {
  description = "Number of periods response time must stay below threshold to trigger scale-out"
  type        = number
  default     = 3
}

variable "response_time_low_scale_in_threshold" {
  description = "Reponse time threshold to trigger scale-in"
  type        = number
  default     = 0.2
}

variable "response_time_low_scale_in_period" {
  description = "Period (in seconds) to evaluate response time usage for scale-in"
  type        = number
  default     = 300  
}

variable "response_time_low_scale_in_evaluation_periods" {
  description = "Number of periods response time must stay below threshold to trigger scale-i "
  type        = number
  default     = 2
}

variable "vpc_id" {
  description = "VPC Id for ASG target group"
  type        = string
  default     = "vpc-06cb2d99ad1a50f3b"
}

variable "cloudwatch_log_group_name_postfix" {
  type    = string
  default = "asg_dev"
}

variable "cpu_high_scale_out_threshold" {
  description = "CPU threshold to trigger scale-out"
  type        = number
  default     = 70
}

variable "cpu_high_scale_out_period" {
  description = "Period (in seconds) over which CPU utilization is evaluated for scale-out"
  type        = number
  default     = 300 
}

variable "cpu_high_scale_out_evaluation_periods" {
  description = "Number of periods CPU must exceed threshold to trigger scale-out"
  type        = number
  default     = 1
}

variable "cpu_low_scale_in_threshold" {
  description = "CPU threshold to trigger scale-in"
  type        = number
  default     = 30 
}

variable "cpu_low_scale_in_period" {
  description  = "Period (in seconds) over which CPU utilization is evaluated for scale-in"
  type         = number
  default      = 300
}

variable "cpu_low_scale_in_evaluation_periods" {
  description = "Number of periods CPU must exceed threshold to trigger scale-in"
  type        = number
  default     = 3
}