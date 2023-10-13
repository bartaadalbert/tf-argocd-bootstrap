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

# (5) Argo namespace check
resource "null_resource" "namespace_check" {
  depends_on = [helm_release.argocd]

  provisioner "local-exec" {
    command = <<-EOH
      until kubectl get namespace ${var.argo_app_namespace}; do 
        echo -e "\033[33mWaiting for namespace ${var.argo_app_namespace}...\033[0m"
        sleep 1 
      done
    EOH
  }
}

# (6) Add private repo
resource "kubectl_manifest" "private_repo_secret" {
  depends_on = [null_resource.namespace_check]
  yaml_body = var.byfile_create && fileexists("${path.module}/secret.yaml") ? file("${path.module}/secret.yaml") : <<-YAML
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

#(7) App destibation ns create
resource "kubectl_manifest" "destination_namespace" {
  yaml_body = <<-YAML
apiVersion: v1
kind: Namespace
metadata:
  name: ${var.destination_namespace}
YAML
}

#(8) Add app to argocd
resource "kubectl_manifest" "argocdApp" {
  depends_on = [kubectl_manifest.private_repo_secret, kubectl_manifest.destination_namespace]
    yaml_body = var.byfile_create && fileexists("${path.module}/app.yaml") ? file("${path.module}/app.yaml") : <<-YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${var.app_name}
  namespace: ${var.argo_app_namespace}
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

#(8) Patch the ArgoCD password
resource "null_resource" "patch_argocd_password" {
  count = var.patch_argocd_password ? 1 : 0
  
  provisioner "local-exec" {
    command = <<-EOF
      kubectl -n argocd patch secret argocd-secret -p \
        '{"stringData": {
          "admin.password": "${var.admin_password}",
          "admin.passwordMtime": "$(date +%FT%T%Z)"
        }}'
    EOF
  }

  depends_on = [helm_release.argocd]
}

