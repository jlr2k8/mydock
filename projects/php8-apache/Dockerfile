FROM joshlrogers/apache

ARG PHP_VERSION
ARG JPEG_VERSION='v9c'
ARG PNG_VERSION='1.6.34'

RUN apt update \
    && apt install -y libgd3 libgd-dev sqlite3 libsqlite3-dev libonig-dev libbz2-dev libzip-dev libzip5

## LibJPEG
RUN    wget http://www.ijg.org/files/jpegsrc.${JPEG_VERSION}.tar.gz --output-document /tmp/jpegsrc.${JPEG_VERSION}.tar.gz \
    && cd /tmp && tar xzf jpegsrc.${JPEG_VERSION}.tar.gz \
    && cd jpeg-9c \
    && ./configure \
    && make clean \
    && make \
    && make install clean \
    && cd

## LibPNG
RUN    wget ftp://ftp-osl.osuosl.org/pub/libpng/src/libpng16/libpng-${PNG_VERSION}.tar.gz --output-document /tmp/libpng-${PNG_VERSION}.tar.gz \
    && cd /tmp && tar xzf libpng-${PNG_VERSION}.tar.gz \
    && cd libpng-${PNG_VERSION} \
    && ./configure \
    && make clean \
    && make \
    && make install clean \
    && cd

# PHP
RUN echo >> /usr/local/apache2/conf/httpd.conf \
    && echo '# LoadModule php_module /usr/local/apache2/modules/libphp.so' >> /usr/local/apache2/conf/httpd.conf \
    && wget http://php.net/get/php-${PHP_VERSION}.tar.bz2/from/this/mirror --output-document /tmp/php-${PHP_VERSION}.tar.bz2 \
    && tar xjf /tmp/php-${PHP_VERSION}.tar.bz2 --directory /tmp \
    && cd /tmp/php-${PHP_VERSION} \
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
        --with-bz2 \
        --enable-opcache=yes \
        --enable-bcmath \
        --with-zip \
    && make clean \
    && make \
    && make install clean \
    && rm -rf /tmp/* \
    && echo >> /usr/local/apache2/conf/inc/load_modules.conf \
    && echo 'LoadModule php_module /usr/local/apache2/modules/libphp.so' >> /usr/local/apache2/conf/inc/load_modules.conf

COPY php.ini /usr/local/lib/php.ini
