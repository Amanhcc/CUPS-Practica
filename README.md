# 🖨️ Gestión CUPS con Docker

Este proyecto automatiza la instalación y configuración del servicio **CUPS** (Common Unix Printing System) en sistemas Ubuntu, permitiendo gestionar impresoras de forma sencilla tanto de manera local como a través de un contenedor Docker.

## 📋 Descripción

El objetivo de esta práctica es proporcionar un entorno aislado y reproducible para el servicio de impresión. El script principal se encarga de la lógica de instalación, mientras que la implementación con Docker asegura que el servicio pueda desplegarse en cualquier entorno Ubuntu sin conflictos de dependencias.

## 📂 Estructura del Proyecto

```text
.
├── gestion_cups.sh      # Script principal de instalación y gestión
└── Dockerfile/          # Carpeta contenedora de la configuración Docker
    └── Dockerfile       # Definición de la imagen Docker
