# logs.tf

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "jenkins_log_group" {
  name              = "/ecs/jenkins-ecs-master"
  retention_in_days = 30

  tags = {
    Name = "jenkins-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "jenkins_log_stream" {
  name           = "jenkins-log-stream"
  log_group_name = aws_cloudwatch_log_group.jenkins_log_group.name
}

