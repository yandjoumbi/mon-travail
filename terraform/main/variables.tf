variable "ssh_key" {
  type = string
  default = "my-key-pair"
}
variable "access_ip" {
  type = string
  default = "10.123.1.0/24"
}

variable "db_name" {
  type = string
  default = "yannickdb"
}

variable "dbuser" {
  type      = string
  sensitive = true
  default = "admin"
}

variable "dbpassword" {
  type      = string
  sensitive = true
  default = "admin12345"
}