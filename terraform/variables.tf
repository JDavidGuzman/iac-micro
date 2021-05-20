variable "region" {
  default = "us-east-1"
}

variable "ssh_user" {
  default = "centos"
}

variable "az" {
  type        = map(number)
  description = "number of subnets"
  default     = { a = 0 }
}

variable "master_num" {
  type        = map(number)
  description = "number of master nodes"
  default     = { a = 0 }
}

variable "worker_num" {
  type        = map(number)
  description = "number of worker nodes"
  default     = { a = 0 }
}