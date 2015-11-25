FROM ubuntu
MAINTAINER Dario Andrei <wouldgo84@gmail.com>

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y build-essential libtool autotools-dev autoconf pkg-config libssl-dev libevent-dev libboost-all-dev libminiupnpc-dev libzmq3-dev bsdmainutils git

RUN git clone https://github.com/bitcoin/bitcoin.git
WORKDIR bitcoin
RUN git fetch --tags && \
  latestTag=$(git describe --tags `git rev-list --tags --max-count=1`) && \
  git checkout $latestTag

RUN mkdir /blockchain && \
  ./autogen.sh && \
  ./configure \
    --enable-cxx \
    --disable-shared \
    --with-pic \
    --prefix=/bitcoin \
    --enable-upnp-default \
    --enable-hardening \
    --with-cli=no \
    --with-gui=no \
    --disable-wallet && \
  make -j 2 && \
  make install

ADD ./conf/bitcoin.conf /opt/bitcoin.conf
ADD ./run /boot
VOLUME ["/blockchain"]

CMD ["/bin/bash", "/boot/run.sh" ]
