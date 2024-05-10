# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  description = "Azure Kubernetes Service Cluster Region"
}

variable "client_id" {
  description = "Azure Kubernetes Service Cluster service principal"
}

variable "client_secret" {
  description = "Azure Kubernetes Service Cluster service secret"
}

variable "cluster_name" {
  description = "Azure Kubernetes Service Cluster Name"
}
