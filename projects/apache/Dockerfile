FROM joshlrogers/debian

RUN wget https://zlib.net/zlib-1.2.11.tar.gz \
	&& tar xzf zlib-1.2.11.tar.gz \
	&& cd zlib-1.2.11 \
	&& ./configure --prefix=/usr \
	&& make clean \
	&& make \
	&& make install clean \
    && cd .. \
	&& rm zlib*.tar.gz

RUN wget https://archive.apache.org/dist/httpd/httpd-2.4.29.tar.bz2 \
	&& tar xjf httpd-2.4.29.tar.bz2 \
	&& rm httpd*.tar.bz2

RUN cd httpd-2.4.29/srclib \
	&& wget https://archive.apache.org/dist/apr/apr-1.6.3.tar.bz2 \
	&& wget https://archive.apache.org/dist/apr/apr-util-1.6.1.tar.bz2 \
	&& tar xjf apr-1.6.3.tar.bz2 \
	&& mv apr-1.6.3 apr

RUN cd httpd-2.4.29/srclib/apr \
	&& ./configure \
	&& make \
	&& make clean \
	&& make install

RUN cd httpd-2.4.29/srclib/ \
    && tar xjf apr-util-1.6.1.tar.bz2 \
    && mv apr-util-1.6.1 apr-util \
    && rm apr*.tar.bz2

RUN cd httpd-2.4.29/srclib/apr-util \
	&& ./configure --with-apr=../apr \
	&& make clean \
	&& make \
	&& make install

RUN cd httpd-2.4.29 \
	&& ./configure \
		--enable-mods-static='speling rewrite so' \
		--enable-ssl \
		--with-ssl=/usr \
		--with-perl \
		--enable-so \
		--enable-proxy \
		--enable-deflate \
		--enable-proxy-html \
		--with-pcre=/usr/local/pcre/bin/pcre-config \
		--with-included-apr \
	&& make clean \
	&& make \
	&& make install clean

COPY conf/ /usr/local/apache2/conf/

RUN ldconfig

ENV PACKAGES_DEBIAN_RM=' \
	make \
	build-essential \
	gcc \
	autoconf \
	wget \
	libexpat1 \
	libexpat1-dev \
	libpcre3-dev \
	libtool \
	libxml2-utils \
	libxml2-dev \
	procps \
'

RUN apt-get purge -y --auto-remove ${PACKAGE_DEBIAN_RM} \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/apache2/htdocs

EXPOSE 80

CMD ["/usr/local/apache2/bin/apachectl", "-D", "FOREGROUND"]