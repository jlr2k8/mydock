FROM debian:bookworm

ENV PACKAGES_DEBIAN=" \
    autoconf \
    build-essential \
    dos2unix \
    gcc \
    libaio-dev \
    libaio1 \
    libexpat1 \
    libexpat1-dev \
    libncurses5 \
    libsasl2-modules \
    libtool \
    libxml2-dev \
    libxml2-utils \
    make \
    nano \
    net-tools \
    numactl \
    procps \
    sudo \
    wget \
"

ENV PCRE_VERSION='8.45'
ENV OPENSSL_VERSION='3.2.0'
ENV CURL_VERSION='8.2.1'

RUN apt update \
    && apt install -y ${PACKAGES_DEBIAN}

RUN wget -O pcre-${PCRE_VERSION}.tar.bz2 https://sourceforge.net/projects/pcre/files/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.bz2/download \
    && tar xjf pcre-${PCRE_VERSION}.tar.bz2 \
    && cd pcre-${PCRE_VERSION} \
    && ./configure \
    && make clean \
    && make \
    && make install \
    && cd

RUN wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
    && tar xzf openssl-${OPENSSL_VERSION}.tar.gz \
    && cd openssl-${OPENSSL_VERSION} \
    && ./config -fPIC --prefix=/usr \
    && make clean \
    && make \
    && make install \
    && ldconfig /usr/lib64 \
    && cd

RUN wget https://curl.se/download/curl-${CURL_VERSION}.tar.bz2 \
    && tar xjf curl-${CURL_VERSION}.tar.bz2 \
    && cd curl-${CURL_VERSION} \
    && ./configure --prefix=/usr --with-ssl=/usr \
    && make clean \
    && make \
    && make install \
    && cd

RUN rm -rf /var/lib/apt/lists/*