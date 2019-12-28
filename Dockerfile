FROM ubuntu:disco

# needed to install tzdata in disco
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  build-essential \
  pkg-config \
  qt5-default \
  libboost-dev \
  libasound2-dev \
  libssl-dev \
  libspeechd-dev \
  libzeroc-ice-dev \
  libpulse-dev \
  libcap-dev \
  libprotobuf-dev \
  protobuf-compiler \
  protobuf-compiler-grpc \
  libprotoc-dev \
  libogg-dev \
  libavahi-compat-libdnssd-dev \
  libsndfile1-dev \
  libgrpc++-dev \
  libxi-dev \
  libbz2-dev \
  qtcreator

RUN mkdir /root/mumble

ENV version=1.3.0
ADD https://github.com/mumble-voip/mumble/archive/${version}.tar.gz /root/mumble/
RUN tar xvfz /root/mumble/${version}.tar.gz -C /root/mumble/
WORKDIR /root/mumble/mumble-${version}

RUN qmake -recursive main.pro CONFIG+="no-client grpc"
RUN make release

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
  libqt5sql5-psql

COPY --from=0 /root/mumble/mumble-master/release/murmurd /usr/bin/murmurd
COPY --from=0 /root/mumble/mumble-master/scripts/murmur.ini /etc/murmur/murmur.ini

# Forward apporpriate ports
EXPOSE 64738/tcp 64738/udp

USER murmur

# Run murmur
ENTRYPOINT ["/opt/murmur/murmur.x86", "-fg", "-v"]
CMD ["-ini", "/etc/murmur.ini"]
