# Clon ligero (backing store)
# El disco resultante apunta al volumen base y solo guarda cambios diferenciales
resource "libvirt_volume" "server1-disk" {
  name           = "server1-linked.qcow2"
  pool           = var.libvirt_pool_name
  base_volume_id = "${var.libvirt_pool_path}/ubuntu2404-base.qcow2"
  format         = "qcow2"
}

# Disco cloud-init con configuración del sistema
resource "libvirt_cloudinit_disk" "server1-cloudinit" {
  name           = "server1-cloudinit.iso"
  pool           = var.libvirt_pool_name
  user_data      = join("\n", ["#cloud-config", yamlencode(local.merged)])
  network_config = ""
}

# Dominio (VM)
resource "libvirt_domain" "server1" {
  name   = "server1ubuntu"
  memory = 1024
  vcpu   = 2


  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }
  disk { volume_id = libvirt_volume.server1-disk.id }
  cloudinit = libvirt_cloudinit_disk.server1-cloudinit.id
}

