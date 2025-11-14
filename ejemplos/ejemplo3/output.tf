output "server1" {
  value = {
    nombre = "server1"
    ip1    = try(libvirt_domain.server1.network_interface[0].addresses[0], "No disponible")
    ip2    = try(libvirt_domain.server1.network_interface[1].addresses[0], "No disponible")
    ip3    = try(libvirt_domain.server1.network_interface[2].addresses[0], "No disponible")
  }
}
