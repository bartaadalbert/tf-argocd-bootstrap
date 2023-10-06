## Terraform ArgoCD Bootstrap
## Overview

This repository contains Terraform configuration files to bootstrap an ArgoCD installation in a Kubernetes cluster. ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes.

##Prerequisites
Before you begin, ensure you have met the following requirements:

- Terraform is installed on your local machine.
- You have the necessary access credentials for your Kubernetes cluster.
- You have a GitHub repository with your application code.
- You have an SSH private key for Git access.

## Getting Started

## Usage

This Terraform configuration provides several resources and modules for setting up ArgoCD and related components. You can customize these resources according to your needs.

The key resources in this project include:

  ```   Creating the ArgoCD installation using Helm (chart: argo-cd).
        Generating an admin password for ArgoCD.
        Patching the ArgoCD service to use LoadBalancer.
        Creating a Git repository secret for ArgoCD.
        Adding an application to ArgoCD.
  ```
  ```module
    module "argocd_bootstrap" {
        source                  = "github.com/bartaadalbert/tf-argocd-bootstrap?ref=master"
        github_repository       = "${var.GITHUB_OWNER}/${var.ARGO_GITHUB_REPO}"
        private_key             = module.tls_private_key.private_key_pem
        kubeconfig              = module.gke_cluster.kubeconfig_path
        app_name                = var.app_name
        destination_namespace   = var.destination_namespace
        project_path            = var.project_path
        project_targetRevision  = var.project_targetRevision

    }
  ```
To customize these resources or adjust any other settings, refer to the argocd.tf file.

## Cleanup

To remove the resources created by this project, run:
```bash terraform destroy```

## Variable Descriptions

Below are descriptions of the variables in the variables.tf file:
## Install Variables (ArgoCD)

    argo_app_namespace: Namespace for the ArgoCD application.
    secret_name: The name of the Secret.
    ssh_private_key: The SSH private key for Git access.

## Helm Release Variables

These variables control the Helm release for ArgoCD:

    redis_ha_enabled: Whether Redis-HA is enabled.
    controller_replicas: Number of controller replicas.
    server_replicas: Number of server replicas.
    server_service_type: Type of service for the server.
    repo_server_replicas: Number of repoServer replicas.
    application_set_replica_count: Replica count for the applicationSet.

## Application Variables

    app_name: Name of the application.
    project_name: Name of the ArgoCD project.
    project_repoURL: Repository URL for the application.
    project_targetRevision: Target revision for the application.
    project_path: Path to the application within the repository.
    project_recurse: Recurse (boolean).
    destination_server: ArgoCD destination server.
    destination_namespace: Namespace on the destination cluster.
    sync_create_namespace: Create the namespace if not exist (boolean).
    sync_prune: Prune resources (boolean).
    sync_selfHeal: Attempt to repair resources (boolean).

## Contributions

Contributions are welcome! If you encounter any issues or have ideas for improvements, feel free to open an issue or submit a pull request.
License
This project is licensed under the MIT License.
Feel free to further customize the README to provide more specific information about your project or any additional instructions.