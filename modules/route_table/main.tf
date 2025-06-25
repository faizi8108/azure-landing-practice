resource "azurerm_route_table" "this" {
  name                          = var.route_table_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = true

}

resource "azurerm_route" "default_route" {
  name                = "default-route"
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.this.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet" # can later be "VirtualAppliance" for firewall
}
