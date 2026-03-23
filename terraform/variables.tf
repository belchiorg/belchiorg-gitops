variable "hcloud_token" { sensitive = true }
variable "cloudflare_api_token" { sensitive = true }
variable "cloudflare_zone_id" { description = "The Zone ID of the domain guilhermebelchior.com" }
variable "kubernetes_cluster_host" {}
variable "kubernetes_cluster_ca"   { sensitive = true }
variable "kubernetes_client_cert"  { sensitive = true }
variable "kubernetes_client_key"   { sensitive = true }
variable "age_private_key"         { sensitive = true }