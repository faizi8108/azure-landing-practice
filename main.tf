resource "azurerm_resource_group" "lz" {
  name     = var.resource_group_name
  location = var.location
}

module "hub_vnet" {
  source                  = "./modules/vnet"
  vnet_name               = "hub-vnet"
  address_space           = ["10.0.0.0/16"]
  location                = var.location
  resource_group_name     = azurerm_resource_group.lz.name
  subnet_name             = "hub-subnet"
  subnet_address_prefixes = ["10.0.1.0/24"]
}

module "spoke_vnet" {
  source                  = "./modules/vnet"
  vnet_name               = "spoke-vnet"
  address_space           = ["10.1.0.0/16"]
  location                = var.location
  resource_group_name     = azurerm_resource_group.lz.name
  subnet_name             = "spoke-subnet"
  subnet_address_prefixes = ["10.1.1.0/24"]
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "hub-to-spoke"
  resource_group_name       = azurerm_resource_group.lz.name
  virtual_network_name      = module.hub_vnet.vnet_name
  remote_virtual_network_id = module.spoke_vnet.vnet_id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
}
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "spoke-to-hub"
  resource_group_name       = azurerm_resource_group.lz.name
  virtual_network_name      = module.spoke_vnet.vnet_name
  remote_virtual_network_id = module.hub_vnet.vnet_id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
}
module "nsg" {
  source              = "./modules/nsg"
  nsg_name            = "web-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.lz.name
}
module "keyvault" {
  source              = "./modules/keyvault"
  kv_name             = "mykv123faizan" # You can change the name if you want
  location            = var.location
  resource_group_name = azurerm_resource_group.lz.name
}
resource "azurerm_subnet_network_security_group_association" "spoke_nsg_assoc" {
  subnet_id                 = module.spoke_vnet.subnet_id
  network_security_group_id = module.nsg.nsg_id
}
module "spoke_route_table" {
  source              = "./modules/route_table"
  route_table_name    = "spoke-rt"
  location            = var.location
  resource_group_name = azurerm_resource_group.lz.name
}

resource "azurerm_subnet_route_table_association" "spoke_rt_assoc" {
  subnet_id      = module.spoke_vnet.subnet_id
  route_table_id = module.spoke_route_table.route_table_id
}
