output "alb_dns" {
  value = aws_lb.three_tier_lb[0].dns_name
}

output "lb_endpoint" {
  value = aws_lb.three_tier_lb[0].dns_name
}

output "lb_tg_name" {
  value = aws_lb_target_group.three_tier_tg[0].name
}

output "lb_tg" {
  value = aws_lb_target_group.three_tier_tg[0].arn
}