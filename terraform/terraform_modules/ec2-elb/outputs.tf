output "instance_ids" {
  value = ["${aws_instance.instance.*.id}"]
}

output "instance_instance_ips" {
  value = ["${aws_instance.instance.*.private_ip}"]
}

output "instance_instance_names" {
  value = ["${aws_instance.instance.*.private_dns}"]
}

output "instance_security_group" {
  value = "${aws_security_group.instanceSG.id}"
}

output "load_balancer_security_group" {
  value = "${aws_security_group.LoadBalSG.id}"
}

output "load_balancer_dns_name" {
  value = "${aws_lb.ServerLB.dns_name}"
}

output "load_balancer_zone_id" {
  value = "${aws_lb.ServerLB.zone_id}"
}

output "load_balancer_arn" {
  value = "${aws_lb.ServerLB.arn}"
}

output "http_listener_arn" {
  value = ["${aws_lb_listener.Server_httplistener.*.arn}"]
}