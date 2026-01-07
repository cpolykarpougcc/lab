terraform {
  required_version = ">= 1.3.0"

  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "~> 2.15"
    }
  }
}

provider "vsphere" {
  vsphere_server       = var.vsphere_server
  user                 = var.vsphere_user
  password             = var.vsphere_password
  allow_unverified_ssl = true
}

# Datacenter
data "vsphere_datacenter" "dc" {
  name = "LAB Datacenter"
}

# Compute Cluster
data "vsphere_compute_cluster" "cluster" {
  name          = "Cluster_G10"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Resource Pool (EXPLICITLY tied to cluster)
data "vsphere_resource_pool" "pool" {
  name               = "Resources"
  compute_cluster_id = data.vsphere_compute_cluster.cluster.id
}

# Datastore
data "vsphere_datastore" "datastore" {
  name          = "DS3"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Network
data "vsphere_network" "network" {
  name          = "SYS_LAB VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Template VM
data "vsphere_virtual_machine" "template" {
  name          = "charis_temp"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Create VM
resource "vsphere_virtual_machine" "terraform_vm" {
  name             = "terraform-test-vm"
  num_cpus         = 2
  memory           = 4096
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type

  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = 50
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "terraform-vm"
        domain    = "lab.local"
      }

      network_interface {
        ipv4_address = "172.31.11.230"
        ipv4_netmask = 24
      }

      ipv4_gateway    = "172.31.11.254"
      dns_server_list = ["172.31.11.10"]
    }
  }
}