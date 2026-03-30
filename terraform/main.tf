resource "hcloud_server" "master_node" {
  name        = "belchior-ubuntu-8gb-hel1-1"
  server_type = "cpx32"
  image       = "ubuntu-24.04"
  location    = "hel1"
}

resource "hcloud_firewall" "k8s_firewall" {
  name = "k8s-firewall"

  # ssh from feedzai vpn
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = ["195.23.0.0/16"]
  }

  # http/https from cloudflare
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = ["173.245.48.0/20", "103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "141.101.64.0/18", "108.162.192.0/18", "190.93.240.0/20", "188.114.96.0/20", "197.234.240.0/22", "198.41.128.0/17", "162.158.0.0/15", "104.16.0.0/13", "104.24.0.0/14", "172.64.0.0/13", "131.0.72.0/22", "195.23.0.0/16"]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = ["173.245.48.0/20", "103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "141.101.64.0/18", "108.162.192.0/18", "190.93.240.0/20", "188.114.96.0/20", "197.234.240.0/22", "198.41.128.0/17", "162.158.0.0/15", "104.16.0.0/13", "104.24.0.0/14", "172.64.0.0/13", "131.0.72.0/22", "195.23.0.0/16"]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "6443"
    source_ips = ["195.23.0.0/16"]
  }

  # anytype sync (coordinator, node, filenode, consensusnode) — TCP
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "33010-33013"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # anytype sync — UDP (QUIC transport)
  rule {
    direction  = "in"
    protocol   = "udp"
    port       = "33020-33023"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

}

# apply the firewall to the server
resource "hcloud_firewall_attachment" "main" {
  firewall_id = hcloud_firewall.k8s_firewall.id
  server_ids  = [hcloud_server.master_node.id]
}

resource "cloudflare_record" "anytype" {
  zone_id = var.cloudflare_zone_id
  name    = "anytype"
  value   = hcloud_server.master_node.ipv4_address
  type    = "A"
  proxied = false # raw TCP/UDP — Cloudflare cannot proxy this traffic
}

resource "cloudflare_record" "root" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  value   = hcloud_server.master_node.ipv4_address
  type    = "A"
  proxied = true
}