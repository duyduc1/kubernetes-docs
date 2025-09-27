resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.asg_name}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scale_policy_cooldown
  scaling_adjustment     = var.scale_out_policy_adjustment


}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.asg_name}-scale_in"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scale_policy_cooldown
  scaling_adjustment     = var.scale_in_policy_adjustment
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name            = "${var.asg_name}-mem-high"
  alarm_description     = "Scale out when mem_used_percent > 80%"
  comparison_operator   = "GreaterThanThreshold"
  evaluation_periods    = var.memory_high_scale_out_evaluation_periods
  metric_name           = "mem_used_percent"
  namespace             = var.metrics_namespace
  period                = var.memory_high_scale_out_period
  statistic             = "Average"
  threshold             = var.memory_high_scale_out_threshold

  alarm_actions = [aws_autoscaling_policy.scale_out.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_low" {
  alarm_name            = "${var.asg_name}-mem-low"
  alarm_description     = "Scale in when mem_used_percent < 50%"
  comparison_operator   = "LessThanThreshold"
  evaluation_periods    = var.memory_low_scale_in_evaluation_periods
  metric_name           = "mem_used_percent"
  namespace             = var.metrics_namespace
  period                = var.memory_low_scale_in_period
  statistic             = "Average"
  threshold             = var.memory_low_scale_in_threshold

  alarm_actions = [aws_autoscaling_policy.scale_in.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "high_response_time" {
  alarm_name            = "${var.asg_name}-high-response-time"
  alarm_description     = "Scale out when response time high > 0.5s"
  comparison_operator   = "GreaterThanThreshold"
  evaluation_periods    = var.response_time_high_scale_out_evaluation_periods
  metric_name           = "TargetResponseTime"
  namespace             = "AWS/ApplicationELB"
  period                = var.response_time_high_scale_out_period
  statistic             = "Average"
  threshold             = var.response_time_high_scale_out_threshold

  dimensions = {
    TargetGroup  = aws_lb_target_group.app_tg.arn_suffix
  }

  alarm_actions = [aws_autoscaling_policy.scale_out.arn]
}

resource "aws_cloudwatch_metric_alarm" "low_response_time" {
  alarm_name            = "${var.asg_name}-low-response-time"
  alarm_description     = "Scale in when response time low < 0.2s"
  comparison_operator   = "LessThanThreshold"
  evaluation_periods    = var.response_time_low_scale_in_evaluation_periods
  metric_name           = "TargetResponseTime"
  namespace             = "AWS/ApplicationELB"
  period                = var.response_time_low_scale_in_period
  statistic             = "Average"
  threshold             = var.response_time_low_scale_in_threshold

  dimensions = {
    TargetGroup  = aws_lb_target_group.app_tg.arn_suffix
  }

  alarm_actions = [aws_autoscaling_policy.scale_in.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name             = "${var.asg_name}-cpu-high"
  namespace              = "AWS/EC2"
  metric_name            = "CPUUtilization"
  statistic              = "Average"
  period                 = var.cpu_high_scale_out_period
  evaluation_periods     = var.cpu_high_scale_out_evaluation_periods
  threshold              = var.cpu_high_scale_out_threshold
  comparison_operator    = "GreaterThanThreshold"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  alarm_description   = "Scale-out when CPU > ${var.cpu_high_scale_out_threshold}% for 5 minutes"
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name             = "${var.asg_name}-cpu-low"
  namespace              = "AWS/EC2"
  metric_name            = "CPUUtilization"
  statistic              = "Average"
  period                 = var.cpu_low_scale_in_period
  evaluation_periods     = var.cpu_low_scale_in_evaluation_periods
  threshold              = var.cpu_low_scale_in_threshold
  comparison_operator    = "LessThanThreshold"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  alarm_description   = "Scale-in When CPU < ${var.cpu_low_scale_in_threshold}% for 15 minutes"
  alarm_actions       = [aws_autoscaling_policy.scale_in.arn]
}