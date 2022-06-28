# ------------------------------------------------------------------------------
# DEFINE SECURITY GROUPS
# ------------------------------------------------------------------------------
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  description = "ECS security group for the Application Load Balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol  = "tcp"
    from_port = 31000
    to_port   = 61000
    self      = true
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------------------------------------------------------------
# CONFIGURE LOAD BALANCER
# ------------------------------------------------------------------------------
resource "aws_lb" "main" {
  name                       = "ecs-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.ecs_sg.id]
  subnets                    = module.vpc.public_subnets
  idle_timeout               = 30
  enable_deletion_protection = false
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.ecs_lb_target_group.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "ecs_lb_target_group" {
  name     = "ecs-target-group"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 10
    unhealthy_threshold = 10
    timeout             = 20
    interval            = 30
    matcher             = "200"
  }
}

# ------------------------------------------------------------------------------
# CONFIGURE CLOUDWATCH
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "ecs-logs"
  retention_in_days = var.log_retention_in_days
}

# ------------------------------------------------------------------------------
# CONFIGURE ECS SERVICE
# ------------------------------------------------------------------------------
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family = "${var.service_name}-app"
  container_definitions = jsonencode([
    {
      name : "scalable-logging"
      cpu : 10
      image : var.ecs_image_url
      essential : true
      memory : 300
      logConfiguration : {
        "logDriver" : "awslogs"
        "options" : {
          "awslogs-group" : "ecs-logs"
          "awslogs-region" : var.aws_region
          "awslogs-stream-prefix" : "ecs-slogging-app"
        }
      },
      mountPoints : [
        {
          "containerPath" : "/usr/local/apache2/htdocs"
          "sourceVolume" : "ecs-volume"
        }
      ],
      portMappings : [
        {
          "containerPort" : 5000
        }
      ],
      environment : [
        {
          name : "DATABASE_URL"
          value : "${var.db_username}:${var.db_password}@${aws_db_instance.slogging_db.address}:${aws_db_instance.slogging_db.port}/${var.db_name}"
        }
      ]
    }
  ])

  volume {
    name = var.ecs_volume
  }

  depends_on = [
    aws_db_instance.slogging_db
  ]
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs_cluster"
}

resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = var.desired_capacity
  iam_role        = aws_iam_role.ecs_service_role.arn
  depends_on      = [aws_lb_listener.alb_listener]
  load_balancer {
    container_name   = var.service_name
    container_port   = 5000
    target_group_arn = aws_lb_target_group.ecs_lb_target_group.arn
  }
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_launch_configuration" "ecs_launch_config" {
  image_id             = data.aws_ami.latest_ecs_ami.image_id
  security_groups      = [aws_security_group.ecs_sg.id]
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=ecs_cluster >> /etc/ecs/ecs.config"
}

# ------------------------------------------------------------------------------
# CONFIGURE AUTO-SCALING CRITERIA
# ------------------------------------------------------------------------------
resource "aws_autoscaling_group" "ecs_asg" {
  name                 = "ecs-asg"
  vpc_zone_identifier  = module.vpc.private_subnets
  launch_configuration = aws_launch_configuration.ecs_launch_config.name

  desired_capacity = var.desired_capacity
  min_size         = var.desired_capacity
  max_size         = var.maximum_capacity
}

resource "aws_appautoscaling_target" "ecs_service_scaling_target" {
  max_capacity       = 5
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${var.service_name}"
  role_arn           = aws_iam_role.autoscaling_role.arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  depends_on         = [aws_ecs_service.service]
}

resource "aws_appautoscaling_policy" "ecs_service_cpu_scale_out_policy" {
  name               = "cpu-target-tracking-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 50.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_autoscaling_policy" "ecs_infra_scale_out_policy" {
  name                   = "ecs_infra_scale_out_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.ecs_asg.name
}

resource "aws_cloudwatch_metric_alarm" "ecs_service_cpu_scale_out_alarm" {
  alarm_name          = "CPU utilization greater than 50%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "50"
  alarm_description   = "Alarm if CPU utilization is greater than 50% of reserved CPU"
  dimensions = {
    "Name"  = "ScalableLoggingCluster"
    "Value" = aws_ecs_cluster.ecs_cluster.name
  }
  alarm_actions = [aws_appautoscaling_policy.ecs_service_cpu_scale_out_policy.arn]
}

resource "aws_cloudwatch_metric_alarm" "ecs_infra_cpu_alarm_high" {
  alarm_name          = "CPU utilization greater than 50%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"
  alarm_description   = "Alarm if CPU too high or metric disappears indicating instance is down"
  dimensions = {
    "Name"  = "AutoScalingGroupName"
    "Value" = aws_autoscaling_group.ecs_asg.name
  }
  alarm_actions = [aws_autoscaling_policy.ecs_infra_scale_out_policy.arn]
}
