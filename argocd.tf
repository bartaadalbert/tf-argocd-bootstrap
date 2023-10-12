# ArgoCD Installation

# (1) Install argocd to cluster
resource "helm_release" "argocd" {
  chart            = "argo-cd"
  name             = "argocd"
  namespace        = var.argo_app_namespace
  repository       = "https://argoproj.github.io/argo-helm"
  create_namespace = true
}

# (2) Argocd create password for admin user
resource "null_resource" "password" {
  depends_on = [helm_release.argocd]
  provisioner "local-exec" {
    command     = "kubectl -n ${var.argo_app_namespace} get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d > ${path.module}/argocd-login.txt"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ${path.module}/argocd-login.txt"
  }

}

# (3) Delete argo admin secret
resource "null_resource" "del-argo-pass" {
  depends_on = [null_resource.password]
  provisioner "local-exec" {
    command = "kubectl -n ${var.argo_app_namespace} delete secret argocd-initial-admin-secret"
  }
}

# (4) Patch argocd server using LB
resource "null_resource" "patch_argocd_server" {
  depends_on = [helm_release.argocd]
  triggers = {
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      kubectl patch svc argocd-server -n ${var.argo_app_namespace} -p '{"spec": {"type": "LoadBalancer"}}'
    EOT
  }
}


# (5) Add private repo
resource "kubectl_manifest" "private_repo_secret" {
  yaml_body = var.byfile_create ? file("${path.module}/secret.yaml") : <<-YAML
apiVersion: v1
kind: Secret
metadata:
  name: ${var.secret_name}
  namespace: ${var.argo_app_namespace}
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: git@github.com:${var.github_repository}
  sshPrivateKey: |
    ${indent(4, var.private_key)}
  insecure: "true"
  enableLfs: "false"
YAML
}

#(6) Add app to argocd
resource "kubectl_manifest" "argocdApp" {
  depends_on = [kubectl_manifest.private_repo_secret]
    yaml_body = var.byfile_create ? file("${path.module}/app.yaml") : <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${var.app_name}
spec:
  destination:
    name: ''
    namespace: ${var.destination_namespace}
    server: ${var.destination_server}
  source:
    path: ${var.project_path}
    repoURL: git@github.com:${var.github_repository}
    targetRevision: ${var.project_targetRevision}
  sources: []
  project: ${var.project_name}
  syncPolicy:
    automated:
      prune: ${var.sync_prune}
      selfHeal: ${var.sync_selfHeal}
    syncOptions:
      - CreateNamespace=${var.sync_create_namespace}
YAML
}


