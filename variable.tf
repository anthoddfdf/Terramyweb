variable "Evirument" {
  type    = string
  default = "dev"
}
variable "ami" {
  type    = string
  default = "ami-0866a3c8686eaeeba"
}
variable "publicipa" {
  type    = bool
  default = true

}
variable "size" {
  default = "t2.micro"
}
variable "cidr_blo" {
  default = ["0.0.0.0/0"]
  
}
variable "environment" {
  type = string
  default = "test"
  
}