terraform {
  required_version = ">= 1.0"
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}


provider "helm" {
  kubernetes {
    config_path = var.kubeconfig
  }
}

 provider "kubectl" {
    config_path = var.kubeconfig
}