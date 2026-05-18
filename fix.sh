#!/bin/bash

# Configuración de rutas y enlaces
URL_GITLAB="https://gitlab.com/vladihl01/pandascript/-/raw/main/PandaScript/Otros/ejecutar/msg"
URL_DROPBOX="https://github.com/joaquin1444/repo/raw/main/sdsd.rar"
DIR_ADM="/etc/adm-lite"
TMP_RAR="/tmp/sdsd.rar"

# Función para obtener la IP Real
get_real_ip() {
    local ip
    ip=$(curl -4 -s --connect-timeout 5 https://api.ipify.org || \
         curl -4 -s --connect-timeout 5 https://ifconfig.me || \
         curl -4 -s --connect-timeout 5 https://icanhazip.com)
    echo "$ip" | tr -d '[:space:]'
}

# Inicio de proceso silencioso
{
    # Sincronización de hora (Opcional, pero recomendado para logs)
    timedatectl set-ntp true > /dev/null 2>&1

    # 1. Asegurar unrar sin interacción
    if ! command -v unrar &> /dev/null; then
        DEBIAN_FRONTEND=noninteractive apt-get update -y
        DEBIAN_FRONTEND=noninteractive apt-get install unrar -y
    fi

    # 2. Descarga del paquete desde Dropbox
    # Se usa -4 y --no-check-certificate por estabilidad en VPS
    wget -4 -q --no-check-certificate --no-dns-cache --tries=3 --timeout=10 -O "$TMP_RAR" "$URL_DROPBOX"

    # 3. Limpieza y gestión de directorios
    if [ -d "$DIR_ADM" ]; then
        # Borra todo excepto la carpeta de usuarios si existe
        find "$DIR_ADM" -mindepth 1 -maxdepth 1 ! -name "userDIR" -exec rm -rf {} +
    else
        mkdir -p "$DIR_ADM"
    fi

    # 4. Extracción de archivos
    if [ -f "$TMP_RAR" ]; then
        unrar x -o+ -inul "$TMP_RAR" "$DIR_ADM/"
    fi

    # 5. Configuración de accesos directos
    rm -f /usr/bin/menu /usr/bin/adm /usr/local/bin/adm
    
    cat <<EOF > /usr/bin/menu
#!/bin/bash
cd /etc/adm-lite && ./menu
EOF

    cat <<EOF > /usr/bin/adm
#!/bin/bash
cd /etc/adm-lite && ./menu
EOF

    cp /usr/bin/menu /usr/local/bin/adm
    
    # 6. Permisos de ejecución
    chmod +x /usr/bin/menu
    chmod +x /usr/bin/adm
    chmod +x /usr/local/bin/adm
    [ -f "$DIR_ADM/menu" ] && chmod +x "$DIR_ADM/menu"
    chmod -R +x "$DIR_ADM"

    # 7. Limpieza de temporales y RAM
    sync && echo 3 > /proc/sys/vm/drop_caches
    rm -f "$TMP_RAR"

} > /dev/null 2>&1

# Salida visual
REAL_IP=$(get_real_ip)
clear
echo -e "\033[1;32m=================================================="
echo -e " ✅ SISTEMA RESTAURADO"
echo -e " 🌐 IP REAL: \033[1;33m${REAL_IP:-Desconocida}\033[1;32m"
echo -e " ⌨️  COMANDO: \033[1;33mmenu\033[1;32m"
echo -e "==================================================\033[0m"
