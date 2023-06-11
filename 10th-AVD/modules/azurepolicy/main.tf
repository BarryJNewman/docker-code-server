resource "azurerm_subscription_policy_assignment" "auditvms" { 
  name = "Adaptive application controls for defining safe applications should be enabled on your machines" 
  subscription_id = "<Subscription_ID>"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d" 
  description = "Shows all virtual machines not using managed disks" 
  display_name = "Audit VMs without managed disks assignment" 
  }