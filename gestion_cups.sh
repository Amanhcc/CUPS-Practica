#!/bin/bash

# ==============================================================================
#  CUPS AUTO-INSTALLER & CONFIGURATOR (UBUNTU)
#  GitHub: Amanhcc/CUPS-Practica
# ==============================================================================

# Colores para la terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Sin color

# Banner de presentación
clear
echo -e "${BLUE}"
echo "  ██████╗██╗   ██╗██████╗ ███████╗"
echo " ██╔════╝██║   ██║██╔══██╗██╔════╝"
echo " ██║     ██║   ██║██████╔╝███████╗"
echo " ██║     ██║   ██║██╔═══╝ ╚════██║"
echo " ╚██████╗╚██████╔╝██║     ███████║"
echo "  ╚═════╝ ╚═════╝ ╚═╝     ╚══════╝"
echo "        SERVER AUTO-CONFIG"
echo -e "${NC}"

# 1. Validación de Root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[!] ERROR: Debes ejecutar este script con sudo.${NC}"
  echo "Ejemplo: sudo bash $0"
  exit 1
fi

# Detectar usuario real
REAL_USER=${SUDO_USER:-$USER}

# 2. Instalación de Dependencias
echo -e "${YELLOW}[*] Actualizando repositorios e instalando paquetes...${NC}"
apt-get update -qq
apt-get install -y cups cups-client printer-driver-all avahi-daemon > /dev/null

# 3. Configuración del Servidor
echo -e "${YELLOW}[*] Configurando cupsd.conf para acceso remoto...${NC}"
cp /etc/cups/cupsd.conf /etc/cups/cupsd.conf.bak

# Activar escucha en puerto 631 y habilitar descubrimiento de red
sed -i 's/Listen localhost:631/Port 631/' /etc/cups/cupsd.conf
sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf

# Inyectar "Allow all" en las secciones de seguridad para acceso total desde la red
for section in "/" "/admin" "/conf"; do
    sed -i "/<Location $section>/,/<\/Location>/ s/Order allow,deny/Order allow,deny\n  Allow all/" /etc/cups/cupsd.conf
done

# 4. Permisos de Usuario y Firewall
echo -e "${YELLOW}[*] Ajustando privilegios para el usuario: $REAL_USER...${NC}"
usermod -aG lpadmin "$REAL_USER"

# Comando oficial para asegurar administración remota
cupsctl --remote-admin --remote-any --share-printers --user-cancel-any

# Configuración del Firewall (UFW)
if command -v ufw >/dev/null && ufw status | grep -q "active"; then
    echo -e "${YELLOW}[*] Abriendo puertos en el firewall (631 y 5353)...${NC}"
    ufw allow 631/tcp > /dev/null
    ufw allow 5353/udp > /dev/null
fi

# 5. Reinicio de Servicios
echo -e "${YELLOW}[*] Reiniciando servicios...${NC}"
systemctl enable cups > /dev/null 2>&1
systemctl restart cups
systemctl restart avahi-daemon

# 6. Reporte Final
IP_LOCAL=$(hostname -I | awk '{print $1}')

echo -e "${GREEN}"
echo "==============================================================="
echo "        CONFIGURACIÓN COMPLETADA EXITOSAMENTE"
echo "==============================================================="
echo -e "${NC}"
echo -e " > ${BLUE}Panel de Control:${NC} http://$IP_LOCAL:631"
echo -e " > ${BLUE}Usuario Admin:${NC}    $REAL_USER"
echo -e " > ${BLUE}Estado Servicio:${NC}  $(systemctl is-active cups)"
echo ""
echo -e "${YELLOW}RECOMENDACIÓN:${NC} Cierra sesión o reinicia para activar los"
echo -e "permisos de administrador de impresoras para $REAL_USER."
echo "==============================================================="
