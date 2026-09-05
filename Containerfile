# da-os — Bazzite adelgazado para tres maquinas AMD (RDNA1 / RDNA3 / RDNA4)
#
# Base: Bazzite stable. NO se baja a Kinoite ni Aurora a proposito:
# el kernel de Bazzite (vendor "OGC", opengamingcollective.org) lleva el
# parche que restaura HDMI 2.1 en amdgpu, bloqueado upstream por el HDMI Forum.

FROM ghcr.io/ublue-os/bazzite:stable

COPY build.sh /tmp/build.sh

RUN --mount=type=cache,dst=/var/cache/libdnf5,sharing=locked \
    /tmp/build.sh && \
    rm -f /tmp/build.sh && \
    rm -rf /tmp/* /var/tmp/* && \
    ostree container commit
