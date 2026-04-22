#!/bin/bash
# ================================================
# Colab Gaming Full - Steam + Heroic + Minecraft + Sunshine
# Soporte para Tailscale o ZeroTier (elige al inicio)
# ================================================

echo "🚀 Iniciando setup completo de Colab Cloud Gaming..."

# Actualizar sistema e instalar dependencias base
apt-get update -qq && apt-get upgrade -y -qq
apt-get install -y -qq wget curl git sudo xfce4 xfce4-goodies xvfb xorg dbus-x11 nvidia-driver-535

# Montar Google Drive para persistencia de juegos
echo "Montando Google Drive..."
from google.colab import drive
drive.mount('/content/drive')
mkdir -p /content/drive/MyDrive/ColabGaming/{SteamLibrary,Heroic,Minecraft}

echo ""
echo "=== ¿Qué VPN quieres usar? ==="
echo "1) Tailscale (más rápido y estable en general)"
echo "2) ZeroTier (más simple, no requiere authkey en el mismo paso)"
echo "3) Ninguna (solo conexión local, no recomendado)"
read -p "Elige una opción (1, 2 o 3): " vpn_choice

case $vpn_choice in
    1)
        echo "→ Instalando Tailscale..."
        curl -fsSL https://tailscale.com/install.sh | sh
        echo ""
        echo "✅ Tailscale instalado."
        echo "Pasos para conectarlo:"
        echo "   1. Ve a https://login.tailscale.com/admin y genera una Auth Key (recomiendo sin expiración)"
        echo "   2. Copia la clave y pégala abajo:"
        read -p "Pega tu Auth Key de Tailscale: " tail_key
        if [ -n "$tail_key" ]; then
            tailscale up --authkey="$tail_key" --hostname=colab-gaming --accept-routes=true
            echo "✅ Tailscale iniciado. Tu IP es:"
            tailscale ip -4
        fi
        ;;
    2)
        echo "→ Instalando ZeroTier..."
        curl -s https://install.zerotier.com | sh
        echo ""
        echo "✅ ZeroTier instalado."
        echo "Pasos para conectarlo:"
        echo "   1. Ve a https://my.zerotier.com y crea una nueva Network (anota el Network ID de 16 dígitos)"
        echo "   2. Pega el Network ID abajo:"
        read -p "Pega tu Network ID de ZeroTier: " zt_network
        if [ -n "$zt_network" ]; then
            zerotier-cli join "$zt_network"
            echo "✅ ZeroTier unido a la red."
            echo "   Ahora ve a https://my.zerotier.com y autoriza este dispositivo (colab-gaming)."
            echo "   Una vez autorizado, obtén tu IP con: zerotier-cli listnetworks"
        fi
        ;;
    3)
        echo "→ Continuando sin VPN (solo para pruebas locales)."
        ;;
    *)
        echo "Opción inválida. Continuando sin VPN."
        ;;
esac

# Instalar Sunshine
echo "Instalando Sunshine..."
wget -q https://github.com/LizardByte/Sunshine/releases/latest/download/sunshine-ubuntu-22.04-amd64.deb -O /tmp/sunshine.deb
apt install -y -qq /tmp/sunshine.deb
rm /tmp/sunshine.deb

# Instalar Steam
echo "Instalando Steam..."
wget -q https://repo.steampowered.com/steam/archive/stable/steam_latest.deb -O /tmp/steam.deb
apt install -y -qq /tmp/steam.deb
rm /tmp/steam.deb

# Instalar Heroic Launcher
echo "Instalando Heroic Games Launcher..."
apt install -y -qq flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y --noninteractive flathub com.heroicgameslauncher.hgl

# Instalar Minecraft (Prism Launcher)
echo "Instalando Prism Launcher para Minecraft..."
apt install -y -qq openjdk-21-jre
wget -q https://github.com/PrismLauncher/PrismLauncher/releases/latest/download/PrismLauncher-Setup-Linux-x86_64.AppImage -O /usr/local/bin/prismlauncher.AppImage
chmod +x /usr/local/bin/prismlauncher.AppImage

# Configuración básica de Sunshine
cat > /etc/sunshine/sunshine.conf << EOF
origin_pin = 1234
port = 47989
address = 0.0.0.0
width = 1920
height = 1080
fps = 60
codec = h264
EOF

echo ""
echo "🎉 ¡Instalación completada!"
echo ""
echo "📋 Pasos finales recomendados:"
echo "   1. Inicia el escritorio y Sunshine:"
echo "      export DISPLAY=:1 && Xvfb :1 -screen 0 1920x1080x24 & sleep 3 && startxfce4 & sunshine &"
echo "   2. Obtén tu IP de la VPN que elegiste (Tailscale o ZeroTier)"
echo "   3. En Moonlight agrega el host con esa IP y usa PIN 1234"
echo ""
echo "Comandos útiles:"
echo "   • Steam:          steam -bigpicture"
echo "   • Heroic:         flatpak run com.heroicgameslauncher.hgl"
echo "   • Minecraft:      prismlauncher.AppImage"
echo "   • Ver IP Tailscale:  tailscale ip -4"
echo "   • Ver IP ZeroTier:   zerotier-cli listnetworks"