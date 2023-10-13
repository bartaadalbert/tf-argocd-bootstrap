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