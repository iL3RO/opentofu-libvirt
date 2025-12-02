#!/bin/bash

echo "=== INICIANDO DESPLIEGUE COMPLETO ==="
echo ""

# 1. OpenTofu
echo "1. EJECUTANDO OPENTOFU..."
cd opentofu
tofu destroy -auto-approve
tofu apply -auto-approve
cd ..
echo "✓ OpenTofu completado"
echo ""

# 2. Esperar
echo "2. ESPERANDO 90 SEGUNDOS..."
sleep 90
echo "✓ Espera completada"
echo ""

# 3. Obtener IPs
echo "3. OBTENIENDO IPs..."
cd opentofu
NGINX_IP=$(tofu output -json | jq -r '.vms.value.apache2.ips[0]')
PHPFPM_IP=$(tofu output -json | jq -r '.vms.value."php-fpm".ips[0]')
MARIADB_IP=$(tofu output -json | jq -r '.vms.value.mariadb.ips[0]')
cd ..

echo "IPs:"
echo "  Nginx:    $NGINX_IP"
echo "  PHP-FPM:  $PHPFPM_IP"
echo "  MariaDB:  $MARIADB_IP"
echo ""

# 4. Configurar Ansible
echo "4. CONFIGURANDO ANSIBLE..."
cd ansible

cat > hosts << EOI
all:
  children:
    servidores_web:
      hosts:
        nginx:
          ansible_host: ${NGINX_IP}
          ansible_user: debian
    servidores_php:
      hosts:
        php-fpm:
          ansible_host: ${PHPFPM_IP}
          ansible_user: debian
    servidores_bd:
      hosts:
        mariadb:
          ansible_host: ${MARIADB_IP}
          ansible_user: debian
  vars:
    ansible_become: yes
    ansible_python_interpreter: /usr/bin/python3
EOI

cat > group_vars/all << EOV
nginx_ip: ${NGINX_IP}
phpfpm_ip: ${PHPFPM_IP}
db_host: ${MARIADB_IP}
wordpress_db_name: wordpress
wordpress_db_user: wordpress_user
wordpress_db_password: wordpress_pass
phpmyadmin_db_host: ${MARIADB_IP}
wordpress_path: /var/www/wordpress
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

# 5. Ejecutar Ansible
echo "5. EJECUTANDO ANSIBLE..."
ansible-playbook site.yaml

cd ..
echo "✓ Ansible completado"
echo ""

# 6. Configurar /etc/hosts
echo "6. CONFIGURANDO /etc/hosts..."
sudo sed -i '/www.example.org/d' /etc/hosts
sudo sed -i '/phpmyadmin.example.org/d' /etc/hosts
echo "$NGINX_IP www.example.org" | sudo tee -a /etc/hosts
echo "$NGINX_IP phpmyadmin.example.org" | sudo tee -a /etc/hosts
echo "✓ /etc/hosts configurado"
echo ""

# 7. Resultado final
echo "=== DESPLIEGUE COMPLETADO ==="
echo ""
echo "🎯 APLICACIONES LISTAS:"
echo "   WordPress:   http://www.example.org"
echo "   phpMyAdmin:  http://phpmyadmin.example.org"
echo ""
echo "🔑 CREDENCIALES:"
echo "   Usuario BD:     wordpress_user"
echo "   Contraseña BD:  wordpress_pass"
echo "   Host BD:        $MARIADB_IP"
echo ""
echo "⚠️  Nota: Espera 30 segundos antes de acceder"
echo ""
