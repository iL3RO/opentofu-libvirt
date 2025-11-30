#!/bin/bash
set -e

echo "=== Despliegue automático del proyecto ==="
echo ""

# Paso 1: Destruir infraestructura existente
echo "1. Destruyendo infraestructura existente..."
cd opentofu
tofu destroy -auto-approve
echo "✓ Infraestructura destruida"
echo ""

# Paso 2: Crear nueva infraestructura
echo "2. Creando nueva infraestructura..."
tofu apply -auto-approve
echo "✓ Infraestructura creada"
echo ""

# Paso 3: Esperar a que las VMs estén completamente listas
echo "3. Esperando a que las VMs estén listas (120 segundos)..."
sleep 120
echo "✓ VMs listas"
echo ""

# Paso 4: Obtener IPs dinámicamente y actualizar inventario
echo "4. Obteniendo IPs y actualizando inventario de Ansible..."
cd ..
eval $(cd opentofu && tofu output -json | jq -r '.vms.value | 
  "nginx_ip=\(.apache2.ips[0])\n" + 
  "phpfpm_ip=\(."php-fpm".ips[0])\n" + 
  "mariadb_ip=\(.mariadb.ips[0])"')

cat > ansible/hosts << EOI
all:
  children:
    servidores_web:
      hosts:
        nginx:
          ansible_host: ${nginx_ip}
          ansible_user: debian
          ansible_ssh_private_key_file: ~/.ssh/id_ed25519
    servidores_php:
      hosts:
        php-fpm:
          ansible_host: ${phpfpm_ip}
          ansible_user: debian
          ansible_ssh_private_key_file: ~/.ssh/id_ed25519
    servidores_bd:
      hosts:
        mariadb:
          ansible_host: ${mariadb_ip}
          ansible_user: debian
          ansible_ssh_private_key_file: ~/.ssh/id_ed25519
  vars:
    ansible_become: yes
    ansible_become_method: sudo
    ansible_become_user: root
    ansible_python_interpreter: /usr/bin/python3
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
EOI

# Actualizar group_vars con las IPs
cat > ansible/group_vars/all << EOV
---
# Variables globales

# IPs de los servidores
nginx_ip: ${nginx_ip}
phpfpm_ip: ${phpfpm_ip}
db_host: 10.0.0.2

# WordPress
wordpress_path: /var/www/wordpress
wordpress_db_name: wordpress
wordpress_db_user: wordpress_user
wordpress_db_password: wordpress_pass

# phpMyAdmin
phpmyadmin_db_host: 10.0.0.2

# Configuración nginx
virtualhosts:
  - name: wordpress
    datos:
      nameserver: www.example.org
      documentroot: /var/www/wordpress
      errorlog: error_wordpress
      accesslog: access_wordpress
  - name: phpmyadmin
    datos:
      nameserver: phpmyadmin.example.org
      documentroot: /var/www/phpmyadmin
      errorlog: error_phpmyadmin
      accesslog: access_phpmyadmin
EOV

echo "✓ Inventario actualizado:"
echo "  nginx: ${nginx_ip}"
echo "  php-fpm: ${phpfpm_ip}"
echo "  mariadb: ${mariadb_ip}"
echo ""

# Paso 5: Actualizar /etc/hosts en la máquina local
echo "5. Actualizando /etc/hosts..."
sudo sed -i '/www.example.org/d' /etc/hosts
sudo sed -i '/phpmyadmin.example.org/d' /etc/hosts
echo "${nginx_ip}  www.example.org" | sudo tee -a /etc/hosts
echo "${nginx_ip}  phpmyadmin.example.org" | sudo tee -a /etc/hosts
echo "✓ /etc/hosts actualizado"
echo ""

# Paso 6: Configurar con Ansible
echo "6. Configurando servicios con Ansible..."
cd ansible
ansible-playbook site.yaml
echo "✓ Configuración completada"
echo ""

echo "==================================================="
echo "✓ DESPLIEGUE COMPLETADO CON ÉXITO"
echo "==================================================="
echo ""
echo "Accede a tus aplicaciones en:"
echo "  WordPress:   http://www.example.org"
echo "  phpMyAdmin:  http://phpmyadmin.example.org"
echo ""
echo "Credenciales de phpMyAdmin:"
echo "  Usuario:     wordpress_user"
echo "  Contraseña:  wordpress_pass"
echo "==================================================="
