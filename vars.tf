

variable "resource_group_name" {
  description     = "Resource Group Name"
  default = "Project1RG"
}



variable "location" {
  description     = "Location"
  default = "eastus"
}


variable "num_instance" {
  description     = "Maximum number of VM instances to be created in the availability set"
  default = "2"
}


variable "image_name" {
  description     = "Name of the Image"
  default = "Proj1UdacityVM"
}
