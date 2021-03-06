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

ENV version=1.3.0
ADD https://github.com/mumble-voip/mumble/archive/${version}.tar.gz /root/
RUN tar xvfz /root/${version}.tar.gz -C /root/
RUN mv /root/mumble-${version} /root/mumble
WORKDIR /root/mumble

RUN qmake -recursive main.pro CONFIG+="no-client grpc"
RUN make release

FROM ubuntu:disco

RUN groupadd -g 1001 -r murmur && useradd -u 1001 -r -g murmur murmur
RUN apt-get update && apt-get install -y \
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
  python2.7 \
  && rm -rf /var/lib/apt/lists/*

COPY --from=0 /root/mumble/release/murmurd /usr/bin/murmurd
COPY --from=0 /root/mumble/scripts/murmur.ini /etc/murmur/murmur.ini

EXPOSE 64738/tcp 64738/udp

USER murmur
CMD /usr/bin/murmurd -v -fg -ini /etc/murmur/murmur.ini
