data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh.tpl")

  vars = {
    metrics_namespace                 = var.metrics_namespace
    cloudwatch_log_group_name_postfix = var.cloudwatch_log_group_name_postfix
  }
}

resource "aws_launch_template" "lt" {
  name_prefix   = var.launch_template_name
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  vpc_security_group_ids = var.vpc_security_group_ids

  user_data = base64encode(data.template_file.user_data.rendered)
}

