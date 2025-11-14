##############################################
# escenario.tf — Definición del escenario
##############################################

locals {

  ##############################################
  # Redes a crear
  ##############################################

  networks = {
    nat-dhcp3 = {
      name      = "nat-dhcp3"
      mode      = "nat"
      domain    = "example.com"
      addresses = ["192.168.100.0/24"]
      bridge    = "virbr25"
      dhcp      = true
      dns       = true
      autostart = true
    }

    muy-aislada3 = {
      name      = "muy-aislada3"
      mode      = "none" # sin conectividad
      bridge    = "virbr27"
      autostart = true
    }
    
    nat-dhcp4 = {
      name      = "nat-dhcp4"
      mode      = "nat"
      domain    = "example2.com"
      addresses = ["192.168.200.0/24"]
      bridge    = "virbr28"
      dhcp      = true
      dns       = true
      autostart = true
    }
  }


  ##############################################
  # Máquinas virtuales a crear
  ##############################################

  servers = {
    server1 = {
      name       = "server1"
      memory     = 1024
      vcpu       = 2
      base_image = "debian13-base.qcow2"

      networks = [
        { network_name = "nat-dhcp3", wait_for_lease = true },
        { network_name = "muy-aislada3" }
      ]

      disks = [
        { name = "data", size = 5 * 1024 * 1024 * 1024 }
      ]

      user_data      = "${path.module}/cloud-init/server1/user-data.yaml"
      network_config = "${path.module}/cloud-init/server1/network-config.yaml"
    }

    server2 = {
      name       = "server2"
      memory     = 1024
      vcpu       = 2
      base_image = "ubuntu2404-base.qcow2"

      networks = [
        { network_name = "muy-aislada3" }
      ]

      user_data      = "${path.module}/cloud-init/server2/user-data.yaml"
      network_config = "${path.module}/cloud-init/server2/network-config.yaml"
    }
  
    server3 = {
      name       = "server3"
      memory     = 1024
      vcpu       = 2
      base_image = "ubuntu2404-base.qcow2"

      networks = [
        { network_name = "nat-dhcp4", wait_for_lease = true },
        { network_name = "muy-aislada3" }
      ]

      user_data      = "${path.module}/cloud-init/server3/user-data.yaml"
      network_config = "${path.module}/cloud-init/server3/network-config.yaml"
    }

  }
}

