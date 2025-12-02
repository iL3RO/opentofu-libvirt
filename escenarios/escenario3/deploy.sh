#!/bin/bash
set -e

echo "=========================================="
echo "  DESPLIEGUE AUTOMÁTICO COMPLETO"
echo "=========================================="

# 1. Destruir y crear infraestructura
echo "1. Gestionando infraestructura..."
cd opentofu
tofu destroy -auto-approve
tofu apply -auto-approve
echo "✓ Infraestructura creada"

# 2. Esperar
echo "2. Esperando 120 segundos..."
sleep 120

# 3. Obtener IPs
echo "3. Obteniendo IPs..."
cd ..
eval $(cd opentofu && tofu output -json | jq -r '.vms.value | 
  "nginx_ip=\(.apache2.ips[0])\n" + 
  "phpfpm_ip=\(."php-fpm".ips[0])\n" + 
  "mariadb_ip=\(.mariadb.ips[0])"')

echo "   nginx: ${nginx_ip}"
echo "   php-fpm: ${phpfpm_ip}"
echo "   mariadb: ${mariadb_ip}"

# 4. Limpiar known_hosts (evitar errores de SSH)
echo "4. Limpiando known_hosts..."
ssh-keygen -f ~/.ssh/known_hosts -R ${nginx_ip} 2>/dev/null || true
ssh-keygen -f ~/.ssh/known_hosts -R ${phpfpm_ip} 2>/dev/null || true
ssh-keygen -f ~/.ssh/known_hosts -R ${mariadb_ip} 2>/dev/null || true

# 5. Actualizar inventario
echo "5. Actualizando inventario..."
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
    ansible_python_interpreter: /usr/bin/python3
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
EOI

# 6. Actualizar /etc/hosts
echo "6. Actualizando /etc/hosts..."
sudo sed -i '/www.example.org/d; /phpmyadmin.example.org/d' /etc/hosts
echo "${nginx_ip}  www.example.org" | sudo tee -a /etc/hosts > /dev/null
echo "${nginx_ip}  phpmyadmin.example.org" | sudo tee -a /etc/hosts > /dev/null

# 7. Probar conectividad SSH
echo "7. Probando conectividad SSH..."
for i in {1..10}; do
  if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null debian@${nginx_ip} 'echo OK' 2>/dev/null; then
    echo "✓ SSH disponible"
    break
  fi
  echo "Esperando SSH... intento $i/10"
  sleep 10
done

# 8. Ejecutar Ansible
echo "8. Configurando con Ansible..."
cd ansible
ansible-playbook site.yaml

echo ""
echo "=========================================="
echo "  ✓ DESPLIEGUE COMPLETADO"
echo "=========================================="
echo ""
echo "🌐 Accede a tus aplicaciones:"
echo "   WordPress:  http://www.example.org"
echo "   phpMyAdmin: http://phpmyadmin.example.org"
echo ""
echo "🔐 Credenciales phpMyAdmin:"
echo "   Usuario:     wordpress_user"
echo "   Contraseña:  wordpress_pass"
echo "   Servidor:    10.0.0.2"
echo ""
echo "=========================================="
