terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "vollgaz-terraform"
    storage_account_name = "vollgaztfstate"
    container_name       = "tfstate"
    key                  = "synapse.terraform.tfstate"

  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "vollgaz_synapse_rg" {
  name     = "vollgaz-synapse-rg"
  location = "West Europe"
  tags = {
    creator = "eric schäfer"
    usage   = "demo"
  }
}

resource "azurerm_storage_account" "vollgaz_synapse_storacc" {
  name                      = "vollgazsynapse"
  resource_group_name       = azurerm_resource_group.vollgaz_synapse_rg.name
  location                  = azurerm_resource_group.vollgaz_synapse_rg.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  is_hns_enabled            = true
  enable_https_traffic_only = true
  lifecycle {
    prevent_destroy = false
  }
  tags = {
    creator = "eric schäfer"
    usage   = "demo"
  }
}

resource "azurerm_storage_data_lake_gen2_filesystem" "vollgaz_synapse_azdl" {
  name               = "vollgaz-synapse-azdl"
  storage_account_id = azurerm_storage_account.vollgaz_synapse_storacc.id
}

# Create directories
resource "azurerm_storage_data_lake_gen2_path" "azdl_path_raw" {
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.vollgaz_synapse_azdl.name
  storage_account_id = azurerm_storage_account.vollgaz_synapse_storacc.id
  resource           = "directory"
  path               = "raw/parking_luxembourg"
}
resource "azurerm_storage_data_lake_gen2_path" "azdl_path_raw2" {
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.vollgaz_synapse_azdl.name
  storage_account_id = azurerm_storage_account.vollgaz_synapse_storacc.id
  resource           = "directory"
  path               = "clean/parking_luxembourg"
}

resource "azurerm_synapse_workspace" "vollgaz_synapse_workspace" {
  name                                 = "vollgaz-synapse-workspace"
  resource_group_name                  = azurerm_resource_group.vollgaz_synapse_rg.name
  location                             = azurerm_resource_group.vollgaz_synapse_rg.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.vollgaz_synapse_azdl.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"

  github_repo {
    account_name    = "e-schafer"
    branch_name     = "master"
    repository_name = "vigilant-pancake"
    root_folder     = "/pipelines"
  }

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_synapse_firewall_rule" "vollgaz_synapse_firewall" {
  name                 = "AllowAll"
  synapse_workspace_id = azurerm_synapse_workspace.vollgaz_synapse_workspace.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}


resource "azurerm_synapse_spark_pool" "vollgaz_synapse_spark" {
  name                 = "vollgazspark"
  synapse_workspace_id = azurerm_synapse_workspace.vollgaz_synapse_workspace.id
  node_size_family     = "MemoryOptimized"
  node_size            = "Small"
  node_count           = 3
  spark_version        = "3.2"
  auto_pause {
    delay_in_minutes = 15
  }
  # library_requirements_content  = filebase64("spark_requirements.txt")
  # library_requirements_filename = "spark_requirements.txt"
  # library_requirements_type     = "PYPI"
  tags = {
    creator = "eric schäfer"
    usage   = "demo"
  }

}

resource "azurerm_synapse_integration_runtime_azure" "vollgaz_runtime" {
  name                 = "VollgazRuntime"
  synapse_workspace_id = azurerm_synapse_workspace.vollgaz_synapse_workspace.id
  location             = "AutoResolve"
  core_count           = 8
  time_to_live_min     = 15
}
