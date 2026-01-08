terraform {
  required_version = ">= 1.3.0"

  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "~> 2.5"
    }
  }
}

provider "vsphere" {
  vsphere_server       = var.vsphere_server
  user                 = var.vsphere_user
  password             = var.vsphere_password
  allow_unverified_ssl = true
}

# ------------------------
# Datacenter
# ------------------------
data "vsphere_datacenter" "dc" {
  name = "LAB Datacenter"
}

# ------------------------
# Compute Cluster
# ------------------------
data "vsphere_compute_cluster" "cluster" {
  name          = "Cluster_G10"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# ------------------------
# Datastore
# ------------------------
data "vsphere_datastore" "datastore" {
  name          = "DS3"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# ------------------------
# Network
# ------------------------
data "vsphere_network" "network" {
  name          = "SYS_LAB VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# ------------------------
# VM Template
# ------------------------
data "vsphere_virtual_machine" "template" {
  name          = "charis_temp"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# ------------------------
# Virtual Machine
# ------------------------
resource "vsphere_virtual_machine" "ubu_testing" {
  name   = "ubu-test"
  folder = var.vsphere_folder

  num_cpus = 2
  memory   = 4096

  guest_id  = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type
  firmware  = data.vsphere_virtual_machine.template.firmware

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  # REQUIRED disk block (do NOT change layout)
  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks[0].size
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "ubu-test"
        domain    = "lab.local"
      }

      network_interface {
        ipv4_address = "172.31.11.221"
        ipv4_netmask = 24
      }

      ipv4_gateway    = "172.31.11.254"
      dns_server_list = ["172.31.11.10"]
      dns_suffix_list = ["lab.local"]
    }
  }
}

# ------------------------
# Outputs
# ------------------------
output "vm_name" {
  value = vsphere_virtual_machine.ubu_testing.name
}

output "vm_ip_addresses" {
  value = vsphere_virtual_machine.ubu_testing.guest_ip_addresses
}