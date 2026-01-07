variable "vsphere_server" {
  description = "vCenter Server FQDN or IP"
  type        = string
}

variable "vsphere_user" {
  description = "vCenter username"
  type        = string
  sensitive   = true
}

variable "vsphere_password" {
  description = "vCenter password"
  type        = string
  sensitive   = true
}