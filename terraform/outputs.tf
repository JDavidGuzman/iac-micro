output "instance_ip" {
  value = {
    for instance in aws_instance.master :
    instance.id => instance.public_ip
  }
}
