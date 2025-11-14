# Clon ligero (backing store)
# El disco resultante apunta al volumen base y solo guarda cambios diferenciales
resource "libvirt_volume" "server1-disk" {
  name           = "server1-linked.qcow2"
  pool           = var.libvirt_pool_name
  base_volume_id = "${var.libvirt_pool_path}/debian13-base.qcow2"
  format         = "qcow2"
}

# Disco cloud-init con configuración del sistema
resource "libvirt_cloudinit_disk" "server1-cloudinit" {
  name           = "server1-cloudinit.iso"
  pool           = var.libvirt_pool_name
  user_data      = join("\n", ["#cloud-config", yamlencode(local.merged)])
  network_config = ""
}

# Disco extra 1
resource "libvirt_volume" "disk-extra1" {
  name   = "server1-disk-extra1.qcow2"
  pool   = var.libvirt_pool_name
  format = "qcow2"
  size   = 1 * 1024 * 1024 * 1024 # 1 GB en bytes
}
# Disco extra 2 de 5gb
resource "libvirt_volume" "disk-extra2" {
  name   = "server1-disk-extra2.qcow2"
  pool   = var.libvirt_pool_name
  format = "qcow2"
  size   = 5 * 5120 * 5120 * 5120 # 1 GB en bytes
}


# Dominio (VM)
resource "libvirt_domain" "server1" {
  name   = "server1"
  memory = 1024
  vcpu   = 2

  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }

  disk { volume_id = libvirt_volume.server1-disk.id }
  # Segundo disco
  disk { volume_id = libvirt_volume.disk-extra1.id }
  cloudinit = libvirt_cloudinit_disk.server1-cloudinit.id

}

