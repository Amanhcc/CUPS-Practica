# 🖨️ Gestión de Servicio CUPS con Docker

Este repositorio contiene una solución automatizada para la instalación y gestión del servicio **CUPS** (Common Unix Printing System) en entornos Ubuntu. El proyecto permite desplegar un servidor de impresión de forma rápida utilizando un script de automatización y contenedores **Docker**.

---

## 📂 Estructura del Proyecto

La organización de archivos es la siguiente:

* `gestion_cups.sh`: Script en Bash que automatiza la instalación y configuración del servicio en el host.
* `Dockerfile/`: Directorio que contiene la configuración de Docker.
    * `Dockerfile`: Archivo con las instrucciones para construir la imagen del servidor CUPS.

---

## 🚀 Requisitos Previos

* Sistema Operativo: **Ubuntu** (o derivados).
* **Docker** instalado y funcionando.
* Permisos de superusuario (**sudo**).

---

## 🛠️ Instalación y Despliegue

### Opción A: Despliegue con Docker (Recomendado)

Para aislar el servicio y evitar conflictos de dependencias, utiliza el contenedor:

1. **Construir la imagen:**
   ```bash
   docker build -t practica-cups ./Dockerfile

2. Lanzar el contenedor:
```bash
    docker run -d -p 631:631 --name cups-server practica-cups

```
Opción B: Ejecución mediante Script Local
Si prefieres instalar el servicio directamente en tu máquina:

Dar permisos de ejecución:
```bash
    chmod +x gestion_cups.sh
```
2.  Ejecutar el script:
```bash
sudo ./gestion_cups.sh
```


🌐 Administración del Servicio
Una vez activado el servicio (ya sea por Docker o mediante el script), puedes acceder al panel de control desde tu navegador:

🔗 URL: http://localhost:631

Desde aquí podrás:

Añadir y compartir impresoras en red.

Gestionar colas de impresión.

Configurar usuarios y permisos de administración.

⚙️ Notas Técnicas
Puerto: El contenedor expone el puerto 631, que es el estándar para el protocolo IPP (Internet Printing Protocol).

Configuración: Si utilizas Docker, asegúrate de que el archivo Dockerfile incluya la instalación de los paquetes cups y cups-pdf.


Práctica realizada por: Amanhcc - 2026
