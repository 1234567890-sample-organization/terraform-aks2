# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.67.0"
    }
  }

  required_version = ">= 0.14"

  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "cluster_rsg" {
  name     = "${var.cluster_name}-k8s-rsg"
  location = var.region
}

resource "azurerm_virtual_network" "cluster_net" {
  name                = "${var.cluster_name}-k8s-net"
  location            = azurerm_resource_group.cluster_rsg.location
  resource_group_name = azurerm_resource_group.cluster_rsg.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "cluster_subnet1" {
  name                 = "internal"
  virtual_network_name = azurerm_virtual_network.cluster_net.name
  resource_group_name  = azurerm_resource_group.cluster_rsg.name
  address_prefixes     = ["10.1.0.0/22"]
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "${var.cluster_name}-k8s"
  location            = azurerm_resource_group.cluster_rsg.location
  resource_group_name = azurerm_resource_group.cluster_rsg.name
  dns_prefix          = "${var.cluster_name}-k8s"

  default_node_pool {
    name           = "system"
    node_count     = 1
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.cluster_subnet1.id
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "apps_np" {
  name                  = "apps"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.cluster.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  vnet_subnet_id        = azurerm_subnet.cluster_subnet1.id
}