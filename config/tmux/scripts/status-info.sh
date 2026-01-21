#!/bin/bash
# Get disk usage
DISK=$(df -h / | awk 'NR==2 {printf "%s/%s", $3, $2}')

# Get ethernet IP
ETH_INTERFACE=$(ip route | grep default | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}' | head -1)
if [ -n "$ETH_INTERFACE" ]; then
	if ip link show "$ETH_INTERFACE" 2>/dev/null | grep -q "state UP"; then
		ETH_IP=$(ip -4 addr show "$ETH_INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
		ETH_INFO="${ETH_IP:-no-ip}"
	else
		ETH_INFO="down"
	fi
else
	ETH_INFO="down"
fi

# Get wifi IP
WIFI_INTERFACE=$(iw dev 2>/dev/null | awk '/Interface/{print $2}' | head -1)
if [ -n "$WIFI_INTERFACE" ]; then
	if ip link show "$WIFI_INTERFACE" 2>/dev/null | grep -q "state UP"; then
		WIFI_IP=$(ip -4 addr show "$WIFI_INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
		WIFI_INFO="${WIFI_IP:-no-ip}"
	else
		WIFI_INFO="down"
	fi
else
	WIFI_INFO="down"
fi

echo "D:$DISK | E:$ETH_INFO | W:$WIFI_INFO"
