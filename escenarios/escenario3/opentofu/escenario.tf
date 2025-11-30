##############################################
# escenario.tf — Escenario proxy + backend
##############################################
locals {
  ##############################################
  # Redes a crear
  ##############################################
  networks = {
    red-externa = {
      name      = "red-externa"
      mode      = "nat"
      domain    = "example.com"
      addresses = ["192.168.200.0/24"]
      bridge    = "br-ex"
      dhcp      = true
      dns       = true
      autostart = true
    }
    red-conf = {
      name      = "red-conf"
      mode      = "none"
      addresses = ["192.168.201.0/24"]
      bridge    = "br-conf"
      autostart = true
    }
    red-datos = {
      name      = "red-datos"
      mode      = "none"
      bridge    = "br-datos"
      autostart = true
    }
  }
  ##############################################
  # Máquinas virtuales a crear
  ##############################################
  servers = {
    apache2 = {
      name       = "apache2"
      memory     = 1024
      vcpu       = 1
      base_image = "debian13-base.qcow2"
      networks = [
        { network_name = "red-externa", wait_for_lease = true },
        { network_name = "red-conf" },
        { network_name = "red-datos" }
      ]
      user_data      = "${path.module}/cloud-init/server1/user-data.yaml"
      network_config = "${path.module}/cloud-init/server1/network-config.yaml"
    }
    mariadb = {
      name       = "mariadb"
      memory     = 1024
      vcpu       = 1
      base_image = "ubuntu2404-base.qcow2"
      networks = [
        { network_name = "red-externa", wait_for_lease = true },
        { network_name = "red-conf" },
        { network_name = "red-datos" }
      ]
      user_data      = "${path.module}/cloud-init/server2/user-data.yaml"
      network_config = "${path.module}/cloud-init/server2/network-config.yaml"
    }
    php-fpm = {
      name       = "php-fpm"
      memory     = 1024
      vcpu       = 1
      base_image = "debian13-base.qcow2"
      networks = [
        { network_name = "red-externa", wait_for_lease = true },
        { network_name = "red-conf" },
        { network_name = "red-datos" }
      ]
      user_data      = "${path.module}/cloud-init/server3/user-data.yaml"
      network_config = "${path.module}/cloud-init/server3/network-config.yaml"
    }
  }
}

########################################
# Crear redes a partir del escenario
########################################

module "network" {
  source = "../../../terraform/modules/network"
  for_each = local.networks

  name      = each.value.name
  mode      = each.value.mode
  domain    = lookup(each.value, "domain", null)
  addresses = lookup(each.value, "addresses", [])
  bridge    = lookup(each.value, "bridge", null)
  dhcp      = lookup(each.value, "dhcp", false)
  dns       = lookup(each.value, "dns", false)
  autostart = lookup(each.value, "autostart", false)
}

########################################
# Crear VMs a partir del escenario
########################################

module "server" {
  source   = "../../../terraform/modules/vm"
  for_each = local.servers

  name           = each.value.name
  memory         = each.value.memory
  vcpu           = each.value.vcpu
  pool_name      = var.libvirt_pool_name
  pool_path      = var.libvirt_pool_path
  base_image     = each.value.base_image
  disks          = lookup(each.value, "disks", [])
  user_data      = each.value.user_data
  network_config = each.value.network_config

  networks = [
    for n in each.value.networks : {
      network_id     = module.network[n.network_name].id
      wait_for_lease = lookup(n, "wait_for_lease", false)
    }
  ]
}
