# ==================================================
# Terraform & Providers
# ==================================================
terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.45.1"
    }
  }
}

provider "azurerm" {
  features {}
}


# ==================================================
# Variables 
# ==================================================
variable "resource_group" { }
variable "location" { }
variable "kv_name" {}
variable "tenant_id" {}
variable tags {
  type        = map
  description = "Collection of the tags referenced by the Azure deployment"
  default = {
    source      = "terraform"
    environment = "dev"
    costCenter  = ""
  }
}

#variable "global_settings" {}
# variable "client_config"      {}
# variable "resource_groups"    {}

variable "ip_whitelist" { }
variable "vnet_subnet_list" { }
variable "settings"           {
  default = {
    sku_name = "standard"
    enabled_for_deployment =  false
    enabled_for_disk_encryption =  false
    enabled_for_template_deployment =  false
    purge_protection_enabled =  false
    soft_delete_retention_days =  7
    enable_rbac_authorization =  false
  }
}

# variable "vnets"              { default = {} }
# variable "azuread_groups"     { default = {} }
# variable "managed_identities" { default = {} }
# variable "diagnostics"        {  default = {} }
# variable "private_dns"        {  default = {} }

# ==================================================
# Resources
# ==================================================
resource "azurerm_key_vault" "keyvault" {
  name                              = var.kv_name
  location                          = var.location
  resource_group_name               = var.resource_group
  tenant_id                         = var.tenant_id
  sku_name                          = try(var.settings.sku_name, "standard")
  enabled_for_deployment            = try(var.settings.enabled_for_deployment, false)
  enabled_for_disk_encryption       = try(var.settings.enabled_for_disk_encryption, false)
  enabled_for_template_deployment   = try(var.settings.enabled_for_template_deployment, false)
  purge_protection_enabled          = try(var.settings.purge_protection_enabled, false)
  soft_delete_retention_days        = try(var.settings.soft_delete_retention_days, 7)
  enable_rbac_authorization         = try(var.settings.enable_rbac_authorization, false)
  timeouts {
    delete = "60m"

  }

  network_acls {
    default_action                    = "Deny"           # Allow / Deny
    bypass                            = "AzureServices"   # AzureServices / None
    ip_rules                          = var.ip_whitelist
    virtual_network_subnet_ids        = var.vnet_subnet_list
  }

  tags       = var.tags
  depends_on = [ ]
}


# resource "azurerm_key_vault" "keyvault" {

output "id" {
  value = azurerm_key_vault.keyvault.id
}

output "vault_uri" {
  value = azurerm_key_vault.keyvault.vault_uri
}


output "name" {
  value = azurerm_key_vault.keyvault.name
}

