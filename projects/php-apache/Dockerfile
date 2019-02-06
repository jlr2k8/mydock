FROM joshlrogers/apache

RUN apt-get update \
    && apt-get install -y libgd3 libgd-dev

## LibJPEG
RUN	wget http://www.ijg.org/files/jpegsrc.v9c.tar.gz --output-document /tmp/jpegsrc.v9c.tar.gz \
	&& cd /tmp && tar xzf jpegsrc.v9c.tar.gz \
	&& cd jpeg-9c \
	&& ./configure \
	&& make clean \
	&& make \
	&& make install clean \
	&& cd ~/

## LibPNG
RUN	wget ftp://ftp-osl.osuosl.org/pub/libpng/src/libpng16/libpng-1.6.34.tar.gz --output-document /tmp/libpng-1.6.34.tar.gz \
	&& cd /tmp && tar xzf libpng-1.6.34.tar.gz \
	&& cd libpng-1.6.34 \
	&& ./configure \
	&& make clean \
	&& make \
	&& make install clean \
	&& cd ~/

# PHP
RUN echo >> /usr/local/apache2/conf/httpd.conf \
    && echo '# LoadModule php7_module modules/libphp7.so' >> /usr/local/apache2/conf/httpd.conf \
    && wget http://php.net/get/php-7.2.4.tar.bz2/from/this/mirror --output-document /tmp/php-7.2.4.tar.bz2 \
	&& tar xjf /tmp/php-7.2.4.tar.bz2 --directory /tmp \
	&& cd /tmp/php-7.2.4 \
	&& ./configure \
		--with-zlib \
		--with-gd \
		--enable-exif \
		--enable-mbstring \
		--with-jpeg-dir \
		--with-png-dir \
		--with-apxs2=/usr/local/apache2/bin/apxs \
		--with-curl \
		--with-openssl=/usr \
		--with-mysqli \
		--with-pdo-mysql \
		--enable-opcache=no \
	&& make clean \
	&& make \
	&& make install clean \
	&& rm -rf /tmp/* \
	&& echo >> /usr/local/apache2/conf/inc/load_modules.conf \
    && echo 'LoadModule php7_module modules/libphp7.so' >> /usr/local/apache2/conf/inc/load_modules.conf

COPY php.ini /usr/local/lib/php.ini