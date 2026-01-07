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

data "vsphere_datacenter" "dc" {
  name = "LAB Datacenter"
}

data "vsphere_resource_pool" "pool" {
  name          = "Resources"
  resource_pool_id = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
}

data "vsphere_datastore" "datastore" {
  name          = "DS3"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "DEV_LAB VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "ubuntu20_04" {
  name          = "ubuntu20-04-temp"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "ubu_testing" {
  name     = "ubu-test"
  num_cpus = 2
  memory   = 4096
  guest_id = "ubuntu64Guest"

  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label            = "disk0"
    size             = 50
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.ubuntu20_04.id

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

output "VM_Name" {
  value = vsphere_virtual_machine.ubu_testing.name
}

output "VM_IP_Address" {
  value = vsphere_virtual_machine.ubu_testing.guest_ip_addresses
}

