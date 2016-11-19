output "STATUS_FQDN" {
  value = "${var.status_hostname}.${var.domain_name}"
}

output "STATUS_IP" {
  value = "${aws_eip.status.public_ip}"
}
