#!/bin/bash
# Solucionar problemas de Nginx

# Detener servicios
sudo systemctl stop nginx
sudo systemctl stop php8.4-fpm

# Crear estructura de directorios
sudo mkdir -p /var/www/html/wordpress
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/

# Crear archivo de prueba
sudo sh -c 'echo "<?php echo \"PHP funciona en \"; echo gethostname(); ?>" > /var/www/html/index.php'
sudo chown www-data:www-data /var/www/html/index.php

# Crear configuración Nginx básica
sudo cat > /etc/nginx/sites-available/wordpress << 'NGINX_EOF'
server {
    listen 80;
    server_name _;
    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
NGINX_EOF

# Habilitar sitio
sudo ln -sf /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Probar configuración
sudo nginx -t

# Iniciar servicios
sudo systemctl start php8.4-fpm
sudo systemctl start nginx

# Verificar
echo "✅ Servicios iniciados"
echo "📡 Accede a: http://$(hostname -I | awk '{print $1}')"
echo "📡 O a: http://www.example.org"
