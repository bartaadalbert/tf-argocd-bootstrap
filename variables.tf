variable "kubeconfig" {
  description = "Kubeconfig path"
  type        = string
  default     = "~/.kube/config"
}

variable "byfile_create" {
  description = "Use your own secret,app yaml files"
  type        = bool
  default     = false
}
#install variables argocd
 
variable "redis_ha_enabled" {
  description = "Whether Redis-HA is enabled"
  type        = bool
  default     = false
}

variable "controller_replicas" {
  description = "Number of controller replicas"
  type        = number
  default     = 1
}

variable "server_replicas" {
  description = "Number of server replicas"
  type        = number
  default     = 1
}

variable "server_service_type" {
  description = "Type of service for the server"
  type        = string
  default     = "LoadBalancer"
}

variable "repo_server_replicas" {
  description = "Number of repoServer replicas"
  type        = number
  default     = 1
}

variable "application_set_replica_count" {
  description = "Replica count for the applicationSet"
  type        = number
  default     = 1
}

variable "patch_argocd_password" {
  description = "Whether to patch the ArgoCD admin password"
  type        = bool
  default     = false
}

variable "admin_password" {
  description = "ArgoCD admin password hash, pass = adm!nArgocd"
  type        = string
  default     = "$2a$12$5iyxQNgijH8CH9/6nh35Qus/GpE/vN1NXGEuHOWAsE0ijrhhiRhmG/n6"
}

variable "http_argo_port" {
  description = "Port to patch for HTTP access to ArgoCD"
  type        = number
  default     = 88
}

variable "https_argo_port" {
  description = "Port to patch for HTTPS access to ArgoCD"
  type        = number
  default     = 8443
}

variable "patch_ports" {
  description = "Whether to patch the ArgoCD ports from 80 and 443 to 88 and 8443"
  type        = bool
  default     = false
}

variable "disable_argo_ssl" {
  description = "Whether to patch the ArgoCD secure or insecure"
  type        = bool
  default     = true
}

#Cert manager

variable "install_cert_manager" {
  description = "Whether to install cert-manager using ArgoCD"
  type        = bool
  default     = false
}

variable "create_cluster_issuer" {
  description = "Whether to create the ClusterIssuer for cert-manager"
  type        = bool
  default     = false
}

variable "acme_secret_ref" {
  description = "Acme SecretRef"
  type        = string
  default     = "letsencrypt-prod"
}

variable "acme_email" {
  description = "Email address used for ACME registration"
  type        = string
  default     = "admin@example.com"
}

variable "acme_server" {
  description = "ACME server URL"
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "acme_solvers" {
  description = "ACME solvers in string format"
  type        = string
  default     = <<-EOT
  - http01:
      ingress:
        class: traefik
  EOT
}

variable "namespace_cert_manager" {
  description = "Namespace for the Cert Manager"
  type        = string
  default     = "cert-manager"
}

variable "cert_manager_version" {
  description = "Version for the Cert Manager"
  type        = string
  default     = "v1.13.1"
}


#END CERT MANGER

#APP variables

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "argocd-app"
}

variable "argo_app_namespace" {
  description = "Namespace for the argo application"
  type        = string
  default     = "argocd"
}

variable "project_name" {
  description = "Name of the ArgoCD project"
  type        = string
  default     = "default"
}

variable "github_repository" {
  description = "Repository URL for the application"
  type        = string
  default     = "bartaadalbert/kbot.git"
}

variable "project_targetRevision" {
  description = "Target revision for the application"
  type        = string
  default     = "HEAD"
}

variable "project_path" {
  description = "Path to the application within the repository"
  type        = string
  default     = "helm"
}
variable "project_recurse" {
  description = "recurse,"
  type        = bool
  default     = false
}

variable "destination_server" {
  description = "ArgoCD destination server"
  type        = string
  default     = "https://kubernetes.default.svc"
}

variable "destination_namespace" {
  description = "Namespace on the destination cluster"
  type        = string
  default     = "default"
}

variable "sync_create_namespace" {
  description = "Create by default the namespace if not exist"
  type        = bool
  default     = true
}

variable "sync_prune" {
  description = "tells ArgoCD to remove (prune) any resources that exist in the cluster but are not defined in your application's YAML"
  type        = bool
  default     = false
}

variable "sync_selfHeal" {
  description = "ArgoCD will automatically attempt to repair any resources that are not in the desired state,"
  type        = bool
  default     = false
}

#Private repo

variable "secret_name" {
  description = "The name of the Secret."
  type        = string
  default     = "private-repo-argocd"
}


variable "private_key" {
  description = "The SSH private key for Git access."
  type        = string
  sensitive = true
}