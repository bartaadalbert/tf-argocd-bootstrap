output "install_yaml" {
  value = <<-EOT
   redis-ha:
    enabled: ${var.redis_ha_enabled}

  controller:
    replicas: ${var.controller_replicas}

  server:
    replicas: ${var.server_replicas}
    service:
      type: ${var.server_service_type}

  repoServer:
    replicas: ${var.repo_server_replicas}

  applicationSet:
    replicaCount: ${var.application_set_replica_count}
  EOT
}

output "argocd_application_yaml" {
  value = <<EOT
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${var.app_name}
  namespace: ${var.argo_app_namespace}
spec:
  project: ${var.project_name}
  source:
    repoURL: ${var.project_repoURL}
    targetRevision: ${var.project_targetRevision}
    path: ${var.project_path}
    directory:
         recurse: ${var.project_recurse}
  destination:
    server: ${var.destination_server}
    namespace: ${var.destination_namespace}
  syncPolicy:
          syncOptions:
          - CreateNamespace=${var.sync_create_namespace}
          automated:
            prune: ${var.sync_prune}
            selfHeal: ${var.sync_selfHeal}
EOT
}

data "local_file" "argo_admin_pass" {
  depends_on = [null_resource.password]
  filename = "${path.module}/argocd-login.txt"
}

output "argo_admin_pass" {
  depends_on = [null_resource.password]
  description = "The argo admin password"
  value       = "${path.module}/argocd-login.txt"
}