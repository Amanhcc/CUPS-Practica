#!/bin/bash

# --- Colores para la interfaz ---
VERDE='\033[0;32m'
AZUL='\033[0;34m'
ROJO='\033[0;31m'
NC='\033[0m' # Sin color

# --- 1. FUNCIÓN DE INFORMACIÓN DE RED Y ESTADO ---
mostrar_info() {
    echo -e "${AZUL}=========================================================${NC}"
    echo -e "${VERDE}DATOS DE RED DE TU EQUIPO:${NC}"
    ip -4 addr show | grep -E "inet " | awk '{print "  > Interfaz: "$NF, "| IP: "$2}'
    
    echo -e "\n${VERDE}ESTADO DEL SERVICIO:${NC}"
    # Verificar servicio local
    if systemctl is-active --quiet cups; then
        echo -e "  [LOCAL]  Status: ${VERDE}ACTIVO${NC} (Puerto 631)"
    else
        echo -e "  [LOCAL]  Status: ${ROJO}INACTIVO${NC}"
    fi
    
    # Verificar contenedor Docker
    if [ "$(docker ps -q -f name=cups-practica)" ]; then
        echo -e "  [DOCKER] Status: ${VERDE}EJECUTÁNDOSE${NC} (Puerto 8080)"
    else
        echo -e "  [DOCKER] Status: ${ROJO}PARADO/NO INSTALADO${NC}"
    fi
    echo -e "${AZUL}=========================================================${NC}"
}

# --- 2. FUNCIONES DE ACCIÓN ---
instalar_local() {
    echo "Instalando CUPS localmente..."
    sudo apt update && sudo apt install -y cups
    sudo systemctl enable --now cups
}

instalar_docker() {
    echo "Construyendo imagen y levantando contenedor en puerto 8080..."
    docker build -t mi-cups-server .
    # Eliminamos si existe uno viejo para evitar errores
    docker rm -f cups-practica 2>/dev/null
    docker run -d -p 8080:631 --name cups-practica mi-cups-server
}

parar_servicio() {
    echo "Deteniendo servicios..."
    sudo systemctl stop cups 2>/dev/null
    docker stop cups-practica 2>/dev/null
}

poner_en_marcha() {
    echo "Arrancando servicios..."
    sudo systemctl start cups 2>/dev/null
    docker start cups-practica 2>/dev/null
}

eliminar_todo() {
    echo "Eliminando rastro del servicio..."
    sudo apt remove --purge cups -y
    docker rm -f cups-practica 2>/dev/null
    docker rmi mi-cups-server 2>/dev/null
}

consultar_logs() {
    echo -e "\n--- MENÚ DE LOGS ---"
    echo "a) Ver errores críticos (Docker)"
    echo "b) Ver historial de acceso (Docker)"
    echo "c) Ver logs del sistema local (Journalctl)"
    read -p "Selecciona tipo de log: " log_opt
    case $log_opt in
        a) docker exec cups-practica cat /var/log/cups/error_log ;;
        b) docker exec cups-practica cat /var/log/cups/access_log ;;
        c) journalctl -u cups --since today ;;
        *) echo "Opción no válida." ;;
    esac
}

# --- 3. LÓGICA DE EJECUCIÓN (PARÁMETROS O MENÚ) ---

# Función que mapea los comandos
ejecutar_comando() {
    case $1 in
        inst-local)  instalar_local ;;
        inst-docker) instalar_docker ;;
        start)       poner_en_marcha ;;
        stop)        parar_servicio ;;
        remove)      eliminar_todo ;;
        logs)        consultar_logs ;;
        edit)        sudo nano /etc/cups/cupsd.conf ;;
        *) echo "Uso: $0 {inst-local|inst-docker|start|stop|remove|logs|edit}" ;;
    esac
}

# Si el usuario pasa un argumento (ej: ./gestion_cups.sh start)
if [ $# -gt 0 ]; then
    ejecutar_comando $1
    exit 0
fi

# Si no hay argumentos, mostrar menú interactivo
clear
mostrar_info
echo -e "1) Instalación (Comandos locales)"
echo -e "2) Instalación (Docker en puerto 8080)"
echo -e "3) Puesta en marcha (Start)"
echo -e "4) Parada (Stop)"
echo -e "5) Eliminación del servicio"
echo -e "6) Consultar logs"
echo -e "7) Editar configuración"
echo -e "8) Salir"
read -p "Seleccione una opción [1-8]: " opcion

case $opcion in
    1) ejecutar_comando inst-local ;;
    2) ejecutar_comando inst-docker ;;
    3) ejecutar_comando start ;;
    4) ejecutar_comando stop ;;
    5) ejecutar_comando remove ;;
    6) ejecutar_comando logs ;;
    7) ejecutar_comando edit ;;
    8) exit 0 ;;
    *) echo "Opción incorrecta" ;;
esac
