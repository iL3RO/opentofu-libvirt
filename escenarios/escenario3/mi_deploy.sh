#!/bin/bash
set -e

echo "=== DESPLIEGUE PASO A PASO ==="
echo ""

echo "PASO 1: Destruir infraestructura anterior"
cd opentofu
tofu destroy -auto-approve
cd ..
echo "Hecho"
echo ""

echo "PASO 2: Crear nueva infraestructura"
cd opentofu
tofu apply -auto-approve
cd ..
echo "Hecho"
echo ""

echo "PASO 3: Esperar 2 minutos"
sleep 120
echo "Hecho"
echo ""

echo "PASO 4: Obtener IPs"
cd opentofu
NGINX_IP=$(tofu output -json | jq -r '.vms.value.apache2.ips[0]')
PHPFPM_IP=$(tofu output -json | jq -r '.vms.value."php-fpm".ips[0]')
MARIADB_IP=$(tofu output -json | jq -r '.vms.value.mariadb.ips[0]')
cd ..

echo "IPs obtenidas:"
echo "Nginx:    $NGINX_IP"
echo "PHP-FPM:  $PHPFPM_IP"
echo "MariaDB:  $MARIADB_IP"
echo ""

echo "PASO 5: Actualizar /etc/hosts"
sudo sed -i '/www.example.org/d' /etc/hosts
sudo sed -i '/phpmyadmin.example.org/d' /etc/hosts
echo "$NGINX_IP  www.example.org" | sudo tee -a /etc/hosts
echo "$NGINX_IP  phpmyadmin.example.org" | sudo tee -a /etc/hosts
echo "Hecho"
echo ""

echo "PASO 6: Configurar manualmente"
echo "Ahora debes configurar manualmente con:"
echo ""
echo "1. Instalar MariaDB en $MARIADB_IP:"
echo "   ssh debian@$MARIADB_IP"
echo "   sudo apt update && sudo apt install -y mariadb-server"
echo "   sudo mysql -e \"CREATE DATABASE wordpress;\""
echo "   sudo mysql -e \"CREATE USER 'wordpress_user'@'%' IDENTIFIED BY 'wordpress_pass';\""
echo "   sudo mysql -e \"GRANT ALL ON wordpress.* TO 'wordpress_user'@'%';\""
echo "   sudo mysql -e \"FLUSH PRIVILEGES;\""
echo ""
echo "2. Instalar PHP-FPM en $PHPFPM_IP:"
echo "   ssh debian@$PHPFPM_IP"
echo "   sudo apt update && sudo apt install -y php8.4-fpm php8.4-mysql"
echo "   sudo sed -i \"s/^listen = .*/listen = 0.0.0.0:9000/\" /etc/php/8.4/fpm/pool.d/www.conf"
echo "   sudo systemctl restart php8.4-fpm"
echo ""
echo "3. Instalar Nginx en $NGINX_IP:"
echo "   ssh debian@$NGINX_IP"
echo "   sudo apt update && sudo apt install -y nginx"
echo ""
echo "=== FIN ==="
