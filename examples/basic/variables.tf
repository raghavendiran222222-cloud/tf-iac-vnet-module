variable "subscription_id" {
  type    = string
  default = "00000000-0000-0000-0000-000000000000"
}

variable "resource_group_name" {
  type    = string
  default = "rg-bdt-terdraform-dev-eus2-001"
}

variable "location" {
  type    = string
  default = "eastus2"
}

variable "vnet_name" {
  type    = string
  default = "vnet-tfwkst-dev-eus2-001"
}

variable "address_space" {
  type    = list(string)
  default = ["10.10.0.0/16"]
}
