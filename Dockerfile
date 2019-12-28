FROM bitnami/minideb:latest

RUN groupadd -g 1001 -r murmur && useradd -u 1001 -r -g murmur murmur
RUN install_packages \
  libcap2 \
  libzeroc-ice3.7 \
  libprotobuf17 \
  libgrpc6 \
  libgrpc++1 \
  libavahi-compat-libdnssd1 \
  libqt5core5a \
  libqt5network5 \
  libqt5sql5 \
  libqt5xml5 \
  libqt5dbus5 \
  libqt5sql5-psql \
  bzip2

ENV version=1.3.0

# Download statically compiled murmur and install it to /opt/murmur
ADD https://github.com/mumble-voip/mumble/releases/download/${version}/murmur-static_x86-${version}.tar.bz2 /opt/
RUN bzcat /opt/murmur-static_x86-${version}.tar.bz2 | tar -x -C /opt -f - && \
    rm /opt/murmur-static_x86-${version}.tar.bz2 && \
    mv /opt/murmur-static_x86-${version} /opt/murmur

# Forward apporpriate ports
EXPOSE 64738/tcp 64738/udp

USER murmur

# Run murmur
ENTRYPOINT ["/opt/murmur/murmur.x86", "-fg", "-v"]
CMD ["-ini", "/etc/murmur.ini"]
