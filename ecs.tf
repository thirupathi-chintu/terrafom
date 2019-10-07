# ecs.tf

resource "aws_ecs_cluster" "jenkins" {
  name = "jenkins-cluster"
}


resource "aws_ecs_task_definition" "jenkins" {
  family                   = "jenkins-master-task"
  execution_role_arn       = aws_iam_role.jenkins_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE","EC2"]
  cpu                      = "1024"
  memory                   = "2048"

  container_definitions = <<EOF
[
    {
        "cpu": 1024,
        "environment": [
            {
                "name": "JAVA_OPTS",
                "value": "-Dhudson.DNSMultiCast.disabled=true"
            }
        ],
        "essential": true,
        "image": "jenkins/jenkins",
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "/ecs/jenkins",
                "awslogs-region": "ap-south-1",
                "awslogs-stream-prefix": "master"
            }
        },
        "mountPoints": [],
        "name": "jenkins-master",
        "portMappings": [
            {
                "containerPort": 8080,
                "hostPort": 8080,
                "protocol": "tcp"
            },
            {
                "containerPort": 50000,
                "hostPort": 50000,
                "protocol": "tcp"
            }
        ],
        "volumesFrom": [],
        "tags": []
    }
]
EOF
}

resource "aws_ecs_service" "jenkins" {
  name            = "jenkins-service"
  cluster         = aws_ecs_cluster.jenkins.id
  task_definition = aws_ecs_task_definition.jenkins.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.jenkins.id
    container_name   = "jenkins-master"
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.jenkins, aws_iam_role_policy_attachment.jenkins_task_execution_role]
}

