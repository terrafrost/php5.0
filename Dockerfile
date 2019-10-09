FROM debian:wheezy

LABEL maintainer="terrafrost@php.net"

RUN printf "deb http://archive.debian.org/debian/ wheezy main non-free contrib\ndeb-src http://archive.debian.org/debian/ wheezy main non-free contrib\ndeb http://archive.debian.org/debian-security/ wheezy/updates main non-free contrib\ndeb-src http://archive.debian.org/debian-security/ wheezy/updates main non-free contrib" > /etc/apt/sources.list

RUN apt-get -o Acquire::Check-Valid-Until=false update && apt-get install -y wget build-essential vim git

RUN cd /tmp \
    && wget --no-check-certificate http://www.openssl.org/source/openssl-0.9.8x.tar.gz \
    && tar xvfz openssl-0.9.8x.tar.gz \
    && cd openssl-0.9.8x \
    && ./config shared --prefix=/usr/local/openssl-0.9.8 \
    && make \
    && make install

RUN cd /tmp \
    && wget --no-check-certificate https://museum.php.net/php5/php-5.0.5.tar.gz \
    && tar xzf php-5.0.5.tar.gz

RUN ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib/ \
    && ln -s /usr/lib/x86_64-linux-gnu/libpng.so /usr/lib/ \
    && ln -s /usr/lib/x86_64-linux-gnu/libmysqlclient.so.18 /usr/lib/ \
    && ln -s /usr/lib/x86_64-linux-gnu/libexpat.so /usr/lib/ \
    && ln -s /usr/lib/x86_64-linux-gnu/libmysqlclient.so /usr/lib/libmysqlclient.so \
    && mkdir /usr/kerberos \
    && ln -s /usr/lib/x86_64-linux-gnu/mit-krb5 /usr/kerberos/lib

RUN apt-get build-dep -y php5

RUN cd /tmp/php-5.0.5/ \
    && sed -i 's/__GMP_BITS_PER_MP_LIMB/GMP_LIMB_BITS/g' ext/gmp/gmp.c \
    && ./configure \
       --with-pdo-pgsql \
       --with-zlib-dir \
       --with-freetype-dir \
       --enable-mbstring \
       --with-libxml-dir=/usr \
       --enable-soap \
       --enable-calendar \
       --with-mhash \
       --with-mcrypt \
       --with-zlib \
       --with-gd \
       --with-pgsql \
       --enable-inline-optimization \
       --with-bz2 \
       --with-zlib \
       --enable-sockets \
       --enable-sysvsem \
       --enable-sysvshm \
       --enable-pcntl \
       --enable-mbregex \
       --with-mhash \
       --with-gmp \
       --enable-bcmath \
       --enable-zip \
       --with-pcre-regex \
       --with-jpeg-dir=/usr \
       --with-png-dir=/usr \
       --enable-gd-native-ttf \
       --with-openssl=/usr/local/openssl-0.9.8 \
       --with-openssl-dir=/usr/local/openssl-0.9.8 \
       --enable-ftp \
       --with-kerberos \
       --with-gettext \
       --with-expat-dir=/usr \
     && make \
     && make install-cli

WORKDIR /root

CMD ["bash"]