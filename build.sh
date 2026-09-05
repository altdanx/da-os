#!/usr/bin/bash
set -euo pipefail

echo "=============== da-os: build ==============="

# ---------------------------------------------------------------------------
# 1. Locales: instalar es/en ANTES de quitar el paquete de 227 MB con todos.
#    Si esto falla, el build para. Es deliberado: sin esto se rompe es_ES.
# ---------------------------------------------------------------------------
dnf5 install -y glibc-langpack-es glibc-langpack-en

# ---------------------------------------------------------------------------
# 2. Paquetes fuera. Todos verificados con `rpm -q --whatrequires`:
#    ninguno tiene dependientes en la imagen 44.20260902.
#    Si uno desaparece upstream, el build falla aqui y te enteras.
# ---------------------------------------------------------------------------
QUITAR=(
  # --- firmware de hardware que no existe en las tres maquinas (todas AMD) ---
  nvidia-gpu-firmware
  iwlwifi-mvm-firmware
  atheros-firmware
  intel-opencl
  intel-igc-libs

  # --- servidores y SDK que nunca vas a usar en un escritorio ---
  mariadb-server
  tailscale
  python3-botocore      # SDK de AWS
  edk2-ovmf             # firmware UEFI para maquinas virtuales

  # --- periferico especifico que no tienes ---
  displaylink
  input-remapper

  # --- gaming: fuera todo menos Steam nativo ---
  lutris
  waydroid-selinux      # antes que waydroid: depende de el
  waydroid
  rom-properties
  rom-properties-kf6
  rom-properties-utils
  rom-properties-common
  steamdeck-kde-presets-desktop   # presets de Steam Deck, no de sobremesa

  # --- peso muerto visual ---
  plasma-workspace-wallpapers     # 255 MB de fondos
  glibc-all-langpacks             # 227 MB, sustituido arriba por es + en
)

dnf5 remove -y "${QUITAR[@]}"

# ---------------------------------------------------------------------------
# 3. Servicios enmascarados. Se enmascaran en /usr (no en /etc) para que
#    aplique tambien a sistemas ya instalados al hacer el rebase.
#    Sus paquetes se conservan porque tienen dependientes o son de sistema.
# ---------------------------------------------------------------------------
MASK=(
  ds-inhibit.service        # inhibidor de suspension de Steam Deck
  cardwired.service         # paquete "cardwire", no aplica en sobremesa
  ModemManager.service      # modem 4G/LTE
  gssproxy.service          # Kerberos para NFS
  systemd-homed.service     # cuentas portables, no las usas
)
for u in "${MASK[@]}"; do
  ln -sf /dev/null "/usr/lib/systemd/system/${u}"
  echo "enmascarado: ${u}"
done

# ---------------------------------------------------------------------------
# 4. Menu: ocultar lanzadores sin desinstalar nada.
#    Reversible por el usuario copiando el .desktop a ~/.local/share/applications
# ---------------------------------------------------------------------------
ocultar() {
  local f="/usr/share/applications/$1"
  [[ -f "$f" ]] || { echo "  (no existe, ignorado: $1)"; return 0; }
  grep -q '^NoDisplay=true' "$f" && return 0
  sed -i '0,/^\[Desktop Entry\]/s//[Desktop Entry]\nNoDisplay=true/' "$f"
  echo "  oculto: $1"
}

echo "--- ocultando lanzadores ---"
for d in \
  org.gnome.Extensions.desktop \
  qv4l2.desktop qvidcap.desktop \
  vim.desktop nvim.desktop \
  htop.desktop btop.desktop \
  cups.desktop \
  ; do ocultar "$d"; done

# ---------------------------------------------------------------------------
# 5. Marca de identidad, para saber en que estas al hacer bootc status
# ---------------------------------------------------------------------------
cat > /usr/share/ublue-os/da-os-release <<EOF
DA_OS_BASE=ghcr.io/ublue-os/bazzite:stable
DA_OS_BUILT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

# ---------------------------------------------------------------------------
# 6. Limpieza
# ---------------------------------------------------------------------------
dnf5 clean all
rm -rf /var/lib/dnf /var/log/*

echo "=============== da-os: hecho ==============="
rpm -qa | wc -l | xargs echo "paquetes finales:"
