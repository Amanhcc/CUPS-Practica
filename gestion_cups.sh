#!/bin/bash

################################################################################
# SCRIPT DE INSTALACIÓN Y CONFIGURACIÓN TOTAL CUPS
# Diseñado para: Automatización completa sin intervención manual.
################################################################################

# --- 1. VALIDACIÓN DE ENTORNO ---
if [ "$EUID" -ne 0 ]; then
  echo "[-] ERROR: Debes ejecutar este script con sudo."
  echo "Comando: sudo bash $0"
  exit 1
fi

# Detectar el usuario real detrás de sudo
REAL_USER=${SUDO_USER:-$USER}

echo "==============================================================="
echo "   INICIANDO CONFIGURACIÓN AUTOMÁTICA DE SERVIDOR CUPS         "
echo "==============================================================="

# --- 2. INSTALACIÓN DE PAQUETES ---
echo "[+] 1/6: Instalando paquetes y drivers universales..."
apt-get update -y
apt-get install -y cups cups-client cups-bsd printer-driver-all avahi-utils

# --- 3. RESPALDO Y CONFIGURACIÓN DE RED ---
echo "[+] 2/6: Configurando acceso remoto (puerto 631)..."
cp /etc/cups/cupsd.conf /etc/cups/cupsd.conf.bak

# Modificar para que escuche en todas las interfaces y no solo local
sed -i 's/Listen localhost:631/Port 631/' /etc/cups/cupsd.conf
sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf

# Abrir el acceso a las rutas críticas (Web, Admin, Config)
# Usamos un bucle para inyectar "Allow all" en las etiquetas Location
for loc in "/" "/admin" "/conf"; do
    sed -i "/<Location $loc>/,/<\/Location>/ s/Order allow,deny/Order allow,deny\n  Allow all/" /etc/cups/cupsd.conf
done

# --- 4. FIREWALL Y PROTOCOLOS DE RED ---
echo "[+] 3/6: Abriendo puertos en Firewall y configurando mDNS..."
if command -v ufw >/dev/null; then
    ufw allow 631/tcp >/dev/null
    ufw allow 5353/udp >/dev/null # Para que se vea en la red (Avahi)
fi

# --- 5. GESTIÓN DE PERMISOS ---
echo "[+] 4/6: Otorgando permisos de administración a '$REAL_USER'..."
usermod -aG lpadmin "$REAL_USER"

# Usar la herramienta oficial cupsctl para asegurar que todo esté activo
cupsctl --remote-admin --remote-any --share-printers --user-cancel-any

# --- 6. LANZAMIENTO DEL SERVICIO ---
echo "[+] 5/6: Reiniciando servicios..."
systemctl enable cups
systemctl restart cups
systemctl restart avahi-daemon # Para que aparezca en Windows/Mac automáticamente

# --- 7. FINALIZACIÓN Y DIAGNÓSTICO ---
IP_LOCAL=$(hostname -I | awk '{print $1}')
echo "[+] 6/6: Generando reporte final..."

echo "==============================================================="
echo "             ¡CONFIGURACIÓN COMPLETADA!                        "
echo "==============================================================="
echo " > URL de administración: http://$IP_LOCAL:631"
echo " > Usuario administrador: $REAL_USER"
echo " > Estado del servicio: $(systemctl is-active cups)"
echo "---------------------------------------------------------------"
echo " NOTA: Si el panel web te pide usuario/contraseña, utiliza las"
echo " credenciales de Linux de '$REAL_USER'."
echo "==============================================================="
