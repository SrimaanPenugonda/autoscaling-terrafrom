resource "aws_launch_template" "asg" {
  name                      = "sample"
  image_id                  = data.aws_ami.ami.id
  instance_type             = "t2.micro"
  update_default_version    = true
}

resource "aws_autoscaling_group" "asg" {
  name                      = "autoscaling-asg"
  max_size                  = 1
  min_size                  = 1
  desired_capacity          = 1
  force_delete              = true
  launch_template {
    id                      = aws_launch_template.asg.id
    version                 = "$Latest"
  }
  availability_zones        = ["us-east-1f"]
  tag { // tags for instances that launch from this asg
    key                     = "Name"
    propagate_at_launch     = true
    value                   = "sample-asg"
  }
}

data "aws_ami" "ami" {
  most_recent   = true
  owners        = ["973714476881"]
  filter {
    name   = "name"
    values = ["Centos-7-DevOps-Practice"]
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_autoscaling_policy" "example" {
  name                   = "sample"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  estimated_instance_warmup = "120"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }
}