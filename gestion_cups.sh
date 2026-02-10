#!/bin/bash

################################################################################
# Script: cups.sh
# Descripción: Instalación y configuración automática de servidor CUPS
# Autor: Adaptado para Amanhcc
################################################################################

# --- 1. VERIFICACIÓN DE PRIVILEGIOS ---
# El script necesita privilegios de root para instalar paquetes y editar /etc/
if [ "$EUID" -ne 0 ]; then
  echo "[-] Error: Este script debe ejecutarse con sudo."
  echo "Uso: sudo bash $0"
  exit 1
fi

# Detectamos quién es el usuario real (no root) para darle permisos después
REAL_USER=${SUDO_USER:-$USER}

echo "[+] Iniciando configuración del servidor de impresión CUPS..."

# --- 2. INSTALACIÓN ---
echo "[+] Actualizando repositorios e instalando CUPS..."
apt-get update
apt-get install -y cups

# --- 3. RESPALDO DE SEGURIDAD ---
# Siempre es buena práctica guardar el original antes de editarlo con sed
echo "[+] Creando copia de seguridad de /etc/cups/cupsd.conf"
cp /etc/cups/cupsd.conf /etc/cups/cupsd.conf.bak

# --- 4. CONFIGURACIÓN DE RED (ACCESO REMOTO) ---
echo "[+] Configurando acceso remoto en el puerto 631..."

# Cambiamos la escucha de local a global
sed -i 's/Listen localhost:631/Port 631/' /etc/cups/cupsd.conf

# Permitimos acceso a las secciones principales (Raíz, Admin y Config)
# Esto inserta 'Allow all' después de la línea 'Order allow,deny' en cada sección
sed -i '/<Location \/>/,/<\/Location>/ s/Order allow,deny/Order allow,deny\n  Allow all/' /etc/cups/cupsd.conf
sed -i '/<Location \/admin>/,/<\/Location>/ s/Order allow,deny/Order allow,deny\n  Allow all/' /etc/cups/cupsd.conf
sed -i '/<Location \/conf>/,/<\/Location>/ s/Order allow,deny/Order allow,deny\n  Allow all/' /etc/cups/cupsd.conf

# --- 5. PERMISOS DE USUARIO ---
echo "[+] Añadiendo al usuario '$REAL_USER' al grupo lpadmin..."
usermod -aG lpadmin "$REAL_USER"

# --- 6. REINICIO Y ACTIVACIÓN DEL SERVICIO ---
echo "[+] Reiniciando el servicio CUPS para aplicar los cambios..."
systemctl enable cups
systemctl restart cups

# --- 7. FINALIZACIÓN ---
IP_LOCAL=$(hostname -I | awk '{print $1}')

echo "---------------------------------------------------------------"
echo " ¡LISTO! El servidor CUPS debería estar funcionando."
echo " Accede a la interfaz web aquí: http://$IP_LOCAL:631"
echo "---------------------------------------------------------------"
echo "NOTA: Si no puedes entrar a la administración, cierra sesión"
echo "o reinicia el equipo para que los cambios de grupo surtan efecto."
