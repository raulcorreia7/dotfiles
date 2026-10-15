#!/bin/sh
# Tmux status info.

# -----------------------------------------------------------------------------
# Disk usage
# -----------------------------------------------------------------------------
DISK=$(df -h / | awk 'NR==2 {printf "%s/%s", $3, $2}')

get_iface() {
  ip route | awk '/default/ {for(i=1;i<=NF;i++) if($i=="dev") print $(i+1); exit}'
}

iface_ip() {
  iface=$1
  ip -4 addr show "$iface" | awk '/inet / {print $2; exit}' | cut -d/ -f1
}

# -----------------------------------------------------------------------------
# Ethernet
# -----------------------------------------------------------------------------
ETH_INTERFACE=$(get_iface)
if [ -n "$ETH_INTERFACE" ]; then
  if ip link show "$ETH_INTERFACE" 2>/dev/null | grep -q "state UP"; then
    ETH_IP=$(iface_ip "$ETH_INTERFACE")
    ETH_INFO="${ETH_IP:-no-ip}"
  else
    ETH_INFO="down"
  fi
else
  ETH_INFO="down"
fi

# -----------------------------------------------------------------------------
# Wi-Fi
# -----------------------------------------------------------------------------
WIFI_INTERFACE=$(iw dev 2>/dev/null | awk '/Interface/{print $2; exit}')
if [ -n "$WIFI_INTERFACE" ]; then
  if ip link show "$WIFI_INTERFACE" 2>/dev/null | grep -q "state UP"; then
    WIFI_IP=$(iface_ip "$WIFI_INTERFACE")
    WIFI_INFO="${WIFI_IP:-no-ip}"
  else
    WIFI_INFO="down"
  fi
else
  WIFI_INFO="down"
fi

echo "D:$DISK | E:$ETH_INFO | W:$WIFI_INFO"
