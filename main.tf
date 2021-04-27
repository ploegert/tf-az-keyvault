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


#   dynamic "network_acls" {
#     for_each = lookup(var.settings, "network", null) == null ? [] : [1]

#     content {
#       bypass         = var.settings.network.bypass
#       default_action = try(var.settings.network.default_action, "Deny")
#       ip_rules       = try(var.settings.network.ip_rules, null)
#       virtual_network_subnet_ids = try(var.settings.network.subnets, null) == null ? null : [
#         for key, value in var.settings.network.subnets : try(var.vnets[var.client_config.landingzone_key][value.vnet_key].subnets[value.subnet_key].id, var.vnets[value.lz_key][value.vnet_key].subnets[value.subnet_key].id)
#       ]
#     }
#   }

#   dynamic "contact" {
#     for_each = lookup(var.settings, "contacts", {})

#     content {
#       email = contact.value.email
#       name  = try(contact.value.name, null)
#       phone = try(contact.value.phone, null)
#     }
#   }
# }


# ==================================================
# Output
# ==================================================
# output "instrumentation_key" {
#   value = azurerm_application_insights.core_ai.instrumentation_key
# }




#+=======================================================================================
# App Insights - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/app_service
#---------------------------------------------------------------------------------------
# id - The ID of the Application Insights component.
# app_id - The App ID associated with this Application Insights component.
# instrumentation_key - The Instrumentation Key for this Application Insights component.
# connection_string - The Connection String for this Application Insights component. (Sensitive)
#+=======================================================================================



#+=======================================================================================
# Data - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/app_service
#----------------------------------------------------------------------------------------
# id - The ID of the Virtual Machine.
# app_id - The App ID associated with this Application Insights component.
# application_type - The type of the component.
# instrumentation_key - The instrumentation key of the Application Insights component.
# connection_string - The connection string of the Application Insights component. (Sensitive)
# location - The Azure location where the component exists.
# retention_in_days - The retention period in days.
# tags - Tags applied to the component.
#+=======================================================================================

# data "azurerm_application_insights" "core_ai" {
#   name                = var.common.application_insights.name
#   resource_group_name = var.common.resource_group
# }


#+=======================================================================================
# Output
# ---------------------------------------------------------------------------------------
# id - The ID of the Virtual Machine.
# app_id - The App ID associated with this Application Insights component.
# application_type - The type of the component.
# instrumentation_key - The instrumentation key of the Application Insights component.
# connection_string - The connection string of the Application Insights component. (Sensitive)
# location - The Azure location where the component exists.
# retention_in_days - The retention period in days.
# tags - Tags applied to the component.
#+=======================================================================================
