output "instance_ip" {
value = aws_instance.master["a"].public_ip 
}
