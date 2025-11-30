#!/bin/bash
set -e

echo "======================================"
echo "DESPLIEGUE COMPLETO DEL PROYECTO"
echo "======================================"

cd ~/github/opentofu-libvirt/escenarios/escenario3

# Destruir infraestructura anterior
echo "1. Destruyendo infraestructura anterior..."
cd opentofu
tofu destroy -auto-approve

# Crear nueva infraestructura
echo "2. Creando nueva infraestructura..."
tofu apply -auto-approve

# Esperar que las VMs arranquen
echo "3. Esperando que las VMs arranquen (60 segundos)..."
sleep 60

# Obtener IPs
echo "4. Obteniendo IPs de las VMs..."
tofu output

# Configurar con Ansible
echo "5. Configurando con Ansible..."
cd ../ansible
ansible-playbook site.yaml -v

echo ""
echo "======================================"
echo "✅ DESPLIEGUE COMPLETADO"
echo "======================================"
echo ""
echo "Accede a:"
echo "  - WordPress: http://www.example.org/"
echo "  - phpMyAdmin: http://phpmyadmin.example.org/"
echo ""
echo "Credenciales phpMyAdmin:"
echo "  Usuario: wordpress_user"
echo "  Contraseña: wordpress_pass"
echo ""
