FROM ubuntu:22.04

# Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    cups \
    cups-client \
    sudo \
    && apt-get clean

# Configurar CUPS para aceptar conexiones externas
RUN cupsctl --remote-admin --remote-any --share-printers

# Crear un usuario administrador para la web UI de CUPS (admin:admin)
RUN useradd -m admin -G lpadmin && echo "admin:admin" | chpasswd

EXPOSE 631

# Arrancar el servicio en primer plano
CMD ["/usr/sbin/cupsd", "-f"]
