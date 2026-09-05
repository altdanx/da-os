# da-os

Bazzite adelgazado para tres maquinas AMD: RDNA1 (5700 XT), RDNA3 (7800 XT),
RDNA4 (9070 XT). Escritorio Plasma + Steam nativo, el resto en Flatpak.

## Por que Bazzite y no Kinoite/Aurora

El kernel de Bazzite (`Vendor: The Linux Community and OGC maintainer(s)`,
opengamingcollective.org) lleva el parche que restaura **HDMI 2.1** en amdgpu,
bloqueado upstream por el HDMI Forum. Bajarse a Kinoite o Aurora lo pierde.

## Que quita

- Firmware de hardware inexistente: NVIDIA, Intel WiFi, Atheros, Intel OpenCL
- Servidores/SDK: mariadb-server, tailscale, python3-botocore (AWS), edk2-ovmf
- Perifericos: displaylink, input-remapper
- Gaming sobrante: lutris, waydroid, rom-properties, presets de Steam Deck
- Peso muerto: 255 MB de fondos, 227 MB de locales (deja es + en)

Total ~1,2 GB. Todos verificados con `rpm -q --whatrequires`: cero dependientes.

## Que NO quita, y por que

**`mangohud`, `vkBasalt` y `terra-gamescope` nativos se quedan.** Las
extensiones Flatpak `org.freedesktop.Platform.VulkanLayer.MangoHud` y
`.vkBasalt` viven en `/var/lib/flatpak/runtime/` y **solo cargan dentro de apps
Flatpak**. Steam nativo lee `/usr/share/vulkan/implicit_layer.d/`. Quitar los
RPM deja todos los juegos de Steam sin overlay ni filtros.

GOverlay en Flatpak si vale: sus permisos son `xdg-config/MangoHud:create` y
`xdg-config/vkBasalt:create`, o sea que configura los nativos correctamente.

`avahi` y `smartd` tambien se quedan (mDNS para impresoras, y plasma-disks).

## Uso

```
just build          # construir en local
just rebase-local   # probar sin publicar (pide sudo)
```

Publicacion: GitHub Actions reconstruye a diario tras el build de Bazzite.
La ISO se genera a mano desde la pestana Actions -> "ISO de instalacion".
