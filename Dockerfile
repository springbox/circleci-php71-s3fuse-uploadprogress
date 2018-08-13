FROM php:7.1-apache

# s3fs-fuse modules
RUN apt-get update -qq
RUN apt-get install -y apt-utils
RUN apt-get install -y build-essential libfuse-dev fuse libcurl4-openssl-dev libxml2-dev libssl-dev mime-support automake libtool wget tar

# install fuse-utils
RUN wget http://http.us.debian.org/debian/pool/main/f/fuse/fuse-utils_2.9.0-2+deb7u2_all.deb -O fuse-utils_2.9.0.deb --remote-encoding=utf-8
RUN dpkg -i fuse-utils_2.9.0.deb

# install s3fs-fuse
RUN curl -L https://github.com/s3fs-fuse/s3fs-fuse/archive/v1.82.tar.gz | tar zxv -C /usr/src
RUN cd /usr/src/s3fs-fuse-1.82 && ./autogen.sh && ./configure --prefix=/usr && make && make install

RUN apt-get update && apt-get install -yqq --no-install-recommends \
  vim \
  rsyslog \
  supervisor \
  cron \
  mysql-client \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libpng-dev \
  locales \
  git \
  sudo \
  && a2enmod rewrite \
  && a2enmod expires \
  && a2enmod headers \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install mysqli pdo_mysql zip mbstring gd exif pcntl opcache \
  && pecl install apcu xdebug \
  && echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini \
  && apt-get clean autoclean && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/Jan-E/uploadprogress.git /tmp/php-uploadprogress && \
  cd /tmp/php-uploadprogress && \
  phpize && \
  ./configure --prefix=/usr && \
  make && \
  make install && \
  echo 'extension=uploadprogress.so' > /usr/local/etc/php/conf.d/uploadprogress.ini && \
  rm -rf /tmp/*
  
