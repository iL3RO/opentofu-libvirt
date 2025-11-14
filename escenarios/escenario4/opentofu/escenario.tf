##############################################
# escenario.tf — Escenario proxy + backend
##############################################

locals {

  ##############################################
  # Redes a crear
  ##############################################

  networks = {
    red-externa-e4 = {
      name      = "red-externa-e4"
      mode      = "nat"
      domain    = "example.com"
      addresses = ["192.168.10.0/24"]
      bridge    = "br-ex-e4"
      dhcp      = false
      dns       = true
      autostart = true
    }

        red-datos-e4 = {
      name      = "red-datos-e4"
      mode      = "none" # sin conectividad
      bridge    = "br-datos"
      autostart = true
    }
  }

  ##############################################
  # Máquinas virtuales a crear
  ##############################################

  servers = {
    balanceador = {
      name       = "balanceador"
      memory     = 1024
      vcpu       = 1
      base_image = "debian13-base.qcow2"

      networks = [
        { network_name = "red-externa-e4"},
        { network_name = "red-datos-e4" }
      ]

      user_data      = "${path.module}/cloud-init/server1/user-data.yaml"
      network_config = "${path.module}/cloud-init/server1/network-config.yaml"
    }

    apache1 = {
      name       = "apache1"
      memory     = 1024
      vcpu       = 1
      base_image = "debian13-base.qcow2"

      networks = [
        { network_name = "red-externa-e4" },
        { network_name = "red-datos-e4" }
      ]

      user_data      = "${path.module}/cloud-init/server2/user-data.yaml"
      network_config = "${path.module}/cloud-init/server2/network-config.yaml"
    }

    apache2 = {
      name       = "apache2"
      memory     = 1024
      vcpu       = 1
      base_image = "debian13-base.qcow2"

      networks = [
        { network_name = "red-externa-e4" },
        { network_name = "red-datos-e4" }
      ]

      user_data      = "${path.module}/cloud-init/server3/user-data.yaml"
      network_config = "${path.module}/cloud-init/server3/network-config.yaml"
    }
    apache3 = {
      name       = "apache3"
      memory     = 1024
      vcpu       = 1
      base_image = "debian13-base.qcow2"

      networks = [
        { network_name = "red-externa-e4" },
        { network_name = "red-datos-e4" }
      ]

      user_data      = "${path.module}/cloud-init/server4/user-data.yaml"
      network_config = "${path.module}/cloud-init/server4/network-config.yaml"
    }
  }
}
