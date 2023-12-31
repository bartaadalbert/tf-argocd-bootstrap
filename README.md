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
        patch_argocd_password   = var.patch_argocd_password
        admin_password          = var.admin_password

    }
  ```
To customize these resources or adjust any other settings, refer to the argocd.tf file.

## Adjusting ArgoCD Password
This configuration allows you to set an initial password for ArgoCD. By default, the password is set to adm!nArgocd. To customize the password:

    Generate a bcrypt hash of your desired password using an online bcrypt hash generator or a command-line tool.
    Use the hashed password within the Terraform configuration to apply as described in the "Getting Started" section.

Example using bcrypt and jq to patch the password:

```bash
  PASSWORD_HASH=$(echo -n 'YourPassword' | bcrypt)
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "'${PASSWORD_HASH}'",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'
```
Note: Replace 'YourPassword' with the desired password. Ensure to keep your passwords secure and follow security best practices.

## Cleanup

To remove the resources created by this project, run:
```bash terraform destroy```

## Variable Descriptions

Below are descriptions of the variables in the variables.tf file:
## Install Variables (ArgoCD)

    argo_app_namespace: Namespace for the ArgoCD application.
    secret_name: The name of the Secret.
    ssh_private_key: The SSH private key for Git access.
    admin_password : The admin password in bcrypted form
    patch_argocd_password : default false

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

### New Features

1. **Patching ArgoCD Ports**:
   By default, ArgoCD uses ports 80 and 443. If you wish to change them, you can use the `patch_ports` option to switch the ports to 88 for HTTP and 8443 for HTTPS.

   ```hcl
   variable "http_argo_port" {
     description = "Port to patch for HTTP access to ArgoCD"
     default     = 88
   }

   variable "https_argo_port" {
     description = "Port to patch for HTTPS access to ArgoCD"
     default     = 8443
   }

   variable "patch_ports" {
     description = "Whether to patch the ArgoCD ports from 80 and 443 to 88 and 8443"
     default     = false
   }
   ```

   To enable this feature, set the `patch_ports` variable to `true`.

2. **Installing Cert Manager with ArgoCD**:
   If you wish to manage certificates within your cluster, you can install the cert-manager using ArgoCD. 

   ```hcl
   variable "install_cert_manager" {
     description = "Whether to install cert-manager using ArgoCD"
     default     = false
   }

   variable "namespace_cert_manager" {
     description = "Namespace for the Cert Manager"
     default     = "cert-manager"
   }

   variable "cert_manager_version" {
     description = "Version for the Cert Manager"
     default     = "v1.13.1"
   }
   ```

   To install cert-manager, set the `install_cert_manager` variable to `true`.

## Creates a ClusterIssuer for Cert-manager with the provided ACME solvers

## Configuration

The following variables can be configured for the module:

| Variable              | Description                                                | Default Value                                      |
|-----------------------|------------------------------------------------------------|----------------------------------------------------|
| `create_cluster_issuer` | Whether to create the `ClusterIssuer` for cert-manager   | `false`                                            |
| `acme_secret_ref`      | The name of the secret reference for ACME                 | `letsencrypt-prod`                                 |
| `acme_email`           | Email address used for ACME registration                  | `admin@example.com`                                |
| `acme_server`          | ACME server URL                                           | `https://acme-v02.api.letsencrypt.org/directory`  |
| `acme_solvers`         | ACME solvers in string format. Adjust as per requirements | `- http01:`<br>`    ingress:`<br>`      class: traefik` |

---

```hcl
module "argocd_cert_manager" {
  source                 = "github.com/bartaadalbert/tf-argocd-bootstrap?ref=master"
  create_cluster_issuer  = true
  acme_secret_ref        = "my-secret-ref"
  acme_email             = "my-email@example.com"
  acme_server            = "https://my-acme-server/directory"
  acme_solvers           = <<-EOT
    - http01:
        ingress:
          class: nginx
    EOT
}

```

## Contributions

Contributions are welcome! If you encounter any issues or have ideas for improvements, feel free to open an issue or submit a pull request.
License
This project is licensed under the MIT License.
Feel free to further customize the README to provide more specific information about your project or any additional instructions.