imagen := "da-os"

# construir en local (rootless, no toca el sistema)
build:
    podman build --pull=newer -t localhost/{{imagen}}:test -f Containerfile .

# comparar con la base: cuantos paquetes y cuanto ocupa
diff: build
    @echo "base:"; podman run --rm ghcr.io/ublue-os/bazzite:stable rpm -qa | wc -l
    @echo "da-os:"; podman run --rm localhost/{{imagen}}:test rpm -qa | wc -l
    @podman images --format "{{{{.Repository}}}}:{{{{.Tag}}}} {{{{.Size}}}}" \
        | grep -E 'bazzite|{{imagen}}'

# pasar la imagen local al storage de root, que es el que ve bootc
export-root: build
    podman save localhost/{{imagen}}:test | sudo podman load

# limpiar
clean:
    podman rmi -f localhost/{{imagen}}:test || true
