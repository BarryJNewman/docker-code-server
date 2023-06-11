#Create Resource Groups based on workloads provided
resource "azurerm_resource_group" "myRGs" {
  name     = var.resource_group_name
  location = var.location
}