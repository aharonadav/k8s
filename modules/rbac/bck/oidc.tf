module "shell_execute" {
  source  = "github.com/matti/terraform-shell-resource"
    command = "echo | openssl s_client -connect oidc.eks.us-west-2.amazonaws.com:443 2>&- | openssl x509 -fingerprint -noout | sed 's/://g' | awk -F= '{print tolower($2)}'"
}

output "shell_stdout" {
  value = module.shell_execute.stdout
}

output "shell_stderr" {
  value = module.shell_execute.stderr
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [module.shell_execute.stdout]
  url             = var.oidc_url
}