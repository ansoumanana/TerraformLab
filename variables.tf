 variable "cidr_bloc" {
   type = list(string)
   default = ["172.20.0.0/16","172.20.10.0/24"]
 }

 variable "ports" {
   type = list(number)
   default = [22,80,443,8080,8081]
 }

 variable "ami" {
   type = string
   default = "ami-0b5eea76982371e91"
 }

 variable "instance" {
   type = object({
     ami = string
     type = string
     key_name=string
   })
   default = {
     ami="ami-0b5eea76982371e91"
     type = "t2.micro"
     key_name ="EC2"
   }
 }