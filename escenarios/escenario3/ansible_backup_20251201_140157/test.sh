#!/bin/bash
set -e

echo "======================================"
echo "PRUEBA RÁPIDA (sin destruir)"
echo "======================================"

cd ~/github/opentofu-libvirt/escenarios/escenario3/ansible

echo "Ejecutando Ansible..."
ansible-playbook site.yaml -v

echo ""
echo "✅ Configuración aplicada"
echo ""
echo "Accede a:"
echo "  - WordPress: http://www.example.org/"
echo "  - phpMyAdmin: http://phpmyadmin.example.org/"
