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
  comparison_operator   = "GreaterThanThreshold"
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