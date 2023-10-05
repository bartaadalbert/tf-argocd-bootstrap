# ArgoCD Installation

# (1)
resource "helm_release" "argocd" {
  chart            = "argo-cd"
  name             = "argocd"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  create_namespace = true
}

# (2)
resource "null_resource" "password" {
  depends_on = [helm_release.argocd]
  provisioner "local-exec" {
    command     = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d > ${path.module}/argocd-login.txt"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ${path.module}/argocd-login.txt"
  }

}

# (3)
resource "null_resource" "del-argo-pass" {
  depends_on = [null_resource.password]
  provisioner "local-exec" {
    command = "kubectl -n argocd delete secret argocd-initial-admin-secret"
  }
}

# (4)
resource "null_resource" "patch_argocd_server" {
  depends_on = [helm_release.argocd]
  triggers = {
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
    EOT
  }
}


# (5)
resource "helm_release" "argocd-apps" {
  depends_on = [helm_release.argocd]
  chart      = "argocd-apps"
  name       = "argocd-apps"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"

  # (6)
  values = [
    <<EOT
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
  ]
}


