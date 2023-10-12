data "local_file" "argo_admin_pass" {
  depends_on = [null_resource.password]
  filename = "${path.module}/argocd-login.txt"
}

output "argo_admin_pass" {
  depends_on = [null_resource.password]
  description = "The argo admin password"
  value       = data.local_file.argo_admin_pass.content
}