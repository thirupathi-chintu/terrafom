# outputs.tf

output "alb_hostname" {
  value = aws_alb.jenkins.dns_name
}

