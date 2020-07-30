FROM arm64v8/debian

COPY qemu-aarch64 /qemu-aarch64

SHELL ["/qemu-aarch64", "--execve", "/qemu-aarch64", "/bin/sh", "-c"]

RUN apt-get update && apt-get -y full-upgrade

ENTRYPOINT [ "/qemu-aarch64", "--execve", "/qemu-aarch64" ]

CMD [ "/bin/bash" ]
