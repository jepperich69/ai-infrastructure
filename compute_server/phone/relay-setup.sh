#!/data/data/com.termux/files/usr/bin/sh
# relay-setup.sh - runs INSIDE Termux on the Android phone. Turns it into the Wake-on-LAN relay for the cellar.
#   setup:     <laptop public key on stdin> | sh relay-setup.sh <cellar MAC> <LAN broadcast>
#              e.g.  cat id_ed25519_cellar.pub | sh relay-setup.sh AA:BB:CC:DD:EE:FF 192.168.1.255
#              (values: compute_server/local/cellar_config.json on the laptop, keys mac and wol_broadcast[0])
#   add key:   <another public key on stdin> | sh relay-setup.sh addkey      (new laptop; keeps the old keys)
#   lockdown:  sh relay-setup.sh lock     (key-only SSH; run only after key login is verified)
# Prerequisites on the phone: Tailscale (Always-on VPN), Termux + Termux:Boot (GitHub builds), battery "Unrestricted",
# `pkg install openssh python`, `passwd`, `sshd`. Full steps: compute_server/README.md, "Rebuilding the phone relay".
set -e
P=/data/data/com.termux/files/usr

add_key() {
    key=$(cat)
    case "$key" in ssh-*) ;; *) echo "ERROR: expected an ssh public key on stdin"; exit 1 ;; esac
    mkdir -p ~/.ssh && chmod 700 ~/.ssh
    grep -qxF "$key" ~/.ssh/authorized_keys 2>/dev/null || echo "$key" >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
}

if [ "$1" = lock ]; then
    sed -i '/^PasswordAuthentication/d' "$P/etc/ssh/sshd_config"
    sed -i "/^KbdInteractiveAuthentication/d" "$P/etc/ssh/sshd_config"; echo "KbdInteractiveAuthentication no" >> "$P/etc/ssh/sshd_config"
    echo 'PasswordAuthentication no' >> "$P/etc/ssh/sshd_config"
    [ -f "$P/var/run/sshd.pid" ] && kill "$(cat "$P/var/run/sshd.pid")" 2>/dev/null || true
    sshd
    echo "OK: password login disabled, sshd restarted (key only)."
    exit 0
fi
if [ "$1" = addkey ]; then
    add_key
    echo "OK: key added."
    exit 0
fi

MAC=$1; BCAST=$2
case "$MAC" in ??:??:??:??:??:??) ;; *) echo "usage: <pubkey> | sh relay-setup.sh <MAC aa:bb:cc:dd:ee:ff> <broadcast>"; exit 1 ;; esac
[ -n "$BCAST" ] || { echo "ERROR: give the LAN broadcast address, e.g. 192.168.1.255"; exit 1; }
HEX=$(echo "$MAC" | tr -d ':')

# 1. laptop key
add_key

# 2. wake command (on PATH, so `ssh cellar-relay wake-cellar` works)
cat > "$P/bin/wake-cellar" <<EOF
#!$P/bin/python
import socket
pkt = b'\xff' * 6 + bytes.fromhex('$HEX') * 16
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
sent = 0
for host in ('$BCAST', '255.255.255.255'):
    for port in (9, 7):
        try:
            s.sendto(pkt, (host, port)); sent += 1
        except OSError as e:
            print('send to', host, port, 'failed:', e)
print('relay: magic packet for $MAC sent (%d/4)' % sent)
EOF
chmod 755 "$P/bin/wake-cellar"

# 3. auto-start after a phone reboot (needs the Termux:Boot app, opened once)
mkdir -p ~/.termux/boot
cat > ~/.termux/boot/start-relay <<EOF
#!$P/bin/sh
termux-wake-lock
sshd
EOF
chmod 755 ~/.termux/boot/start-relay

termux-wake-lock 2>/dev/null || true
echo "OK: key added, wake-cellar installed, boot script in ~/.termux/boot/start-relay"
