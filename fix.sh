#!/bin/bash
URL_DROPBOX="https://www.dropbox.com/scl/fi/2gx5sk95piequoz1xs4gx/sdsd.rar?rlkey=9sakiqnoydsnek2pbepz1c138&st=e0zyskmm&dl=1"
DIR_ADM="/etc/adm-lite"
TMP_RAR="/tmp/sdsd.rar"

get_real_ip() {
    local ip
    ip=$(curl -4 -s --connect-timeout 5 https://api.ipify.org || \
         curl -4 -s --connect-timeout 5 https://ifconfig.me || \
         curl -4 -s --connect-timeout 5 https://icanhazip.com)
    echo "$ip" | tr -d '[:space:]'
}
{
    echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf
    sysctl -w net.ipv4.tcp_fastopen=3
    sysctl -w net.ipv4.tcp_low_latency=1
    timedatectl set-ntp true > /dev/null 2>&1

    # Asegurar unrar sin interacción
    if ! command -v unrar &> /dev/null; then
        DEBIAN_FRONTEND=noninteractive apt-get update -y
        DEBIAN_FRONTEND=noninteractive apt-get install unrar -y
    fi
    wget -4 -q --no-check-certificate --no-dns-cache --tries=3 --timeout=10 -O "$TMP_RAR" "$URL_DROPBOX"

    if [ -d "$DIR_ADM" ]; then
        find "$DIR_ADM" -mindepth 1 -maxdepth 1 ! -name "userDIR" -exec rm -rf {} +
    else
        mkdir -p "$DIR_ADM"
    fi


    if [ -f "$TMP_RAR" ]; then
        unrar x -o+ -inul "$TMP_RAR" "$DIR_ADM/"
    fi

 
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
    chmod +x /usr/bin/menu
    chmod +x /usr/bin/adm
    chmod +x /usr/local/bin/adm
    chmod +x "$DIR_ADM/menu"
    chmod -R +x "$DIR_ADM"
    

    sync && echo 3 > /proc/sys/vm/drop_caches

    rm -f "$TMP_RAR"

} > /dev/null 2>&1
REAL_IP=$(get_real_ip)
clear
echo -e "\033[1;32m=================================================="
echo -e " ✅ SISTEMA OPTIMIZADO Y RESTAURADO"
echo -e " 🌐 IP REAL: \033[1;33m${REAL_IP:-Desconocida}\033[1;32m"
echo -e "==================================================\033[0m"