#!/bin/bash

# --- Funciones de Información ---
show_info() {
    echo "=== DATOS DE RED ==="
    ip -4 addr show | grep inet | awk '{print $2}'
    echo "--------------------"
    echo "ESTADO DEL SERVICIO:"
    systemctl is-active cups || echo "Inactivo (o en Docker)"
    echo "===================="
}

install_local() {
    sudo apt update && sudo apt install -y cups
    sudo systemctl enable --now cups
    echo "CUPS instalado localmente."
}

install_docker() {
    docker build -t mi-cups .
    docker run -d -p 631:631 --name cups-server mi-cups
    echo "CUPS desplegado en Docker (Puerto 631)."
}

# --- Lógica de Parámetros y Menú ---
run_action() {
    case $1 in
        install-cmd) install_local ;;
        install-docker) install_docker ;;
        start) sudo systemctl start cups || docker start cups-server ;;
        stop) sudo systemctl stop cups || docker stop cups-server ;;
        remove) sudo apt remove --purge cups -y || docker rm -f cups-server ;;
        logs) journalctl -u cups --since "1 day ago" ;;
        edit) nano /etc/cups/cupsd.conf ;;
        *) echo "Opción no válida" ;;
    esac
}

# Si hay parámetros, ejecutar y salir
if [ $# -gt 0 ]; then
    run_action $1
    exit 0
fi

# Menú interactivo
show_info
echo "1. Instalar (Comandos)"
echo "2. Instalar (Docker)"
echo "3. Arrancar"
echo "4. Parar"
echo "5. Eliminar"
echo "6. Ver Logs"
echo "7. Editar Configuración"
read -p "Seleccione una opción: " opt

case $opt in
    1) run_action install-cmd ;;
    2) run_action install-docker ;;
    3) run_action start ;;
    4) run_action stop ;;
    5) run_action remove ;;
    6) run_action logs ;;
    7) run_action edit ;;
esac
