FROM joshlrogers/debian

ARG APACHE_VERSION
ARG APR_VERSION='1.7.0'
ARG APR_UTIL_VERSION='1.6.1'
ARG ZLIB_VERSION='1.3.1'

RUN wget https://zlib.net/zlib-${ZLIB_VERSION}.tar.gz \
	&& tar xzf zlib-${ZLIB_VERSION}.tar.gz \
	&& cd zlib-${ZLIB_VERSION} \
	&& ./configure --prefix=/usr \
	&& make clean \
	&& make \
	&& make install clean \
    && cd .. \
	&& rm zlib*.tar.gz

RUN wget https://archive.apache.org/dist/httpd/httpd-${APACHE_VERSION}.tar.bz2 \
	&& tar xjf httpd-${APACHE_VERSION}.tar.bz2 \
	&& rm httpd*.tar.bz2

RUN cd httpd-${APACHE_VERSION}/srclib \
	&& wget https://archive.apache.org/dist/apr/apr-${APR_VERSION}.tar.bz2 \
	&& wget https://archive.apache.org/dist/apr/apr-util-${APR_UTIL_VERSION}.tar.bz2 \
	&& tar xjf apr-${APR_VERSION}.tar.bz2 \
	&& mv apr-${APR_VERSION} apr

RUN cd httpd-${APACHE_VERSION}/srclib/apr \
	&& ./configure \
	&& make \
	&& make clean \
	&& make install

RUN cd httpd-${APACHE_VERSION}/srclib/ \
    && tar xjf apr-util-${APR_UTIL_VERSION}.tar.bz2 \
    && mv apr-util-${APR_UTIL_VERSION} apr-util \
    && rm apr*.tar.bz2

RUN cd httpd-${APACHE_VERSION}/srclib/apr-util \
	&& ./configure --with-apr=../apr \
	&& make clean \
	&& make \
	&& make install

RUN cd httpd-${APACHE_VERSION} \
	&& ./configure \
		--enable-mods-static='speling rewrite so' \
		--enable-ssl \
		--with-ssl=/usr \
		--with-perl \
		--enable-so \
		--enable-proxy \
		--enable-deflate \
		--enable-proxy-html \
		--with-pcre=/usr/local/bin/pcre-config \
		--with-included-apr \
	&& make clean \
	&& make \
	&& make install clean

RUN mkdir -p /usr/local/apache2/conf/inc/vhosts

COPY conf/ /usr/local/apache2/conf/
COPY path.sh /etc/profile.d/path.sh

RUN ldconfig

ENV PACKAGES_DEBIAN_RM=" \
	make \
	build-essential \
	gcc \
	autoconf \
	wget \
	libexpat1 \
	libexpat1-dev \
	libpcre2-dev \
	libtool \
	libxml2-utils \
	libxml2-dev \
	procps \
"

RUN apt-get purge -y --auto-remove ${PACKAGE_DEBIAN_RM} \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/apache2/htdocs

EXPOSE 80

CMD ["/usr/local/apache2/bin/apachectl", "-D", "FOREGROUND"]