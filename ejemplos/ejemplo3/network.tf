##############################################
# network.tf — Definición de redes libvirt
##############################################

##############################################
# Red NAT con DHCP 
##############################################

resource "libvirt_network" "nat-dhcp" {
  name      = "nat-dhcp"
  mode      = "nat"
  domain    = "example.com"
  addresses = ["192.168.100.0/24"]
 # bridge    = "virbr30"
  dhcp { enabled = true }
  dns { enabled = true }
  autostart = true
}
##############################################
# La nueva Red NAT con DHCP 
##############################################

resource "libvirt_network" "nat-dhcp2" {
  name      = "nat-dhcp2"
  mode      = "nat"
  domain    = "example.com"
  addresses = ["192.168.101.0/24"]
#  bridge    = "virbr31"
  dhcp { enabled = true }
  dns { enabled = true }
  autostart = true
}

##############################################
# Red NAT sin DHCP
##############################################

#resource "libvirt_network" "nat-static" {
#  name      = "nat-static"
#  mode      = "nat"
#  addresses = ["192.168.110.0/24"]
#  bridge    = "virbr11"
#  dhcp {enabled = false}
#  autostart = true
#}

##############################################
# Red aislada con DHCP
##############################################

#resource "libvirt_network" "aislada-dhcp" {
#  name      = "aislada-dhcp"
#  mode      = "isolated"
#  domain    = "example.com"
#  addresses = ["192.168.120.0/24"]
# bridge    = "virbr12"
# dhcp {enabled = true}
# dns {enabled = true}
#  autostart = true
#}

##############################################
# Red aislada sin DHCP
##############################################

#resource "libvirt_network" "aislada-static" {
#  name      = "aislada-static"
#  mode      = "isolated"
#    addresses = ["192.168.130.0/24"]
# bridge    = "virbr13"
# dhcp {enabled = false}
#  autostart = true
#}

##############################################
# Red muy aislada
##############################################
#resource "libvirt_network" "muy-aislada" {
#  name   = "muy-aislada"
#  mode   = "none"      # sin conectividad
# bridge    = "virbr14"
#  autostart = true
#}

##############################################
# Red puenteada (bridge) con interfaz física br0
##############################################
#resource "libvirt_network" "bridge-br0" {
#  name   = "bridge-br0"
#  mode   = "bridge"
#  bridge = "br0"
#  autostart = true
#}
