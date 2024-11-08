# hcloud.pkr.hcl

packer {
  required_plugins {
    hcloud = {
      version = ">= 1.0.0"
      source  = "github.com/hetznercloud/hcloud"
    }
  }
}

variable "location" {
  type    = string
  default = "hel1"
}

variable "server_type" {
  type    = string
  default = "cax21"
}

variable "talos_version" {
  type    = string
  default = "v1.8.2"
}

variable "talos_asset" {
  type    = string
  default = "hcloud-arm64"
}

variable "base_image" {
  type    = string
  default = "debian-12"
}

locals {
  image = "https://factory.talos.dev/image/376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba/${var.talos_version}/${var.talos_asset}.raw.xz"
}

source "hcloud" "talos" {
  rescue       = "linux64"
  image        = var.base_image
  location     = var.location
  server_type  = var.server_type
  ssh_username = "root"

  snapshot_name = "talos-${var.talos_version}"
  snapshot_labels = {
    type    = "infra",
    os      = "talos",
    version = "${var.talos_version}",
  }
}

build {
  sources = ["source.hcloud.talos"]

  provisioner "shell" {
    inline = [
      "apt-get install -y wget",
      "wget -O /tmp/talos.raw.xz ${local.image}",
      "xz -d -c /tmp/talos.raw.xz | dd of=/dev/sda && sync",
    ]
  }
}