variable "vnet_name" {}
variable "address_space" {}
variable "location" {}
variable "resource_group_name" {}

variable "subnet_name" {
  description = "Name of the subnet to be created"
  type        = string
}

variable "subnet_address_prefixes" {
  description = "List of address prefixes for the subnet"
  type        = list(string)
}
