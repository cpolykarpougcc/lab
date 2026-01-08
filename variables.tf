variable "vsphere_server" {
  description = "vCenter or ESXi server FQDN/IP"
  type        = string
}

variable "vsphere_user" {
  description = "vSphere username"
  type        = string
}

variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  sensitive   = true
}

variable "vsphere_folder" {
  description = "VM folder path relative to Datacenter /vm"
  type        = string
}