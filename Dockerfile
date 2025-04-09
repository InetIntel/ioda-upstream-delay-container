FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive
ENV APP_ENV=docker

# Install necessary packages
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    autoconf \
    automake \
    libtool \
    zlib1g-dev \
    libpcap-dev \
    curl \
    wget \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-dev \
    net-tools \
    rsync \
    && rm -rf /var/lib/apt/lists/*

# Scamper
RUN curl -L https://www.caida.org/catalog/software/scamper/code/scamper-cvs-20240725.tar.gz -o scamper.tar.gz && \
    tar xzf scamper.tar.gz && \
    cd scamper-cvs-20240725 && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf scamper-cvs-20240725 scamper.tar.gz

# wandio
RUN mkdir -p /src && cd /src && \
    curl -LO https://github.com/LibtraceTeam/wandio/archive/refs/tags/4.2.6-1.tar.gz && \
    tar zxf 4.2.6-1.tar.gz && \
    cd wandio-4.2.6-1 && \
    ./bootstrap.sh && \
    ./configure && \
    make && \
    make install && \
    ldconfig

# libipmeta
RUN git clone https://github.com/CAIDA/libipmeta.git /libipmeta && \
    cd /libipmeta && \
    git submodule init && \
    git submodule update && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    ldconfig

# PyIPMeta
RUN git clone https://github.com/CAIDA/pyipmeta.git /pyipmeta && \
    cd /pyipmeta && \
    python3 setup.py build_ext && \
    python3 setup.py install

# Yarrp
RUN git clone https://github.com/cmand/yarrp.git /yarrp
WORKDIR /yarrp
RUN ./bootstrap && ./configure && make


# Application setup
WORKDIR /
RUN git clone https://github.com/InetIntel/ioda-upstream-delay-docker-application /ioda-upstream-delay-application
RUN mkdir -p /data/tmp /data/results
RUN date +%s > /tmp/timestamp 
RUN cd /ioda-upstream-delay-application && git pull
RUN cd /ioda-upstream-delay-application/yrp2text && \
    make
WORKDIR /ioda-upstream-delay-application
RUN python3 -m pip install -r requirements.txt
RUN python3 -m pip install elasticsearch[async]


# run
WORKDIR /ioda-upstream-delay-application
CMD ["python3", "-i", "main.py"]
