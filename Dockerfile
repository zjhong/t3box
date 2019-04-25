FROM php:7.2-apache
LABEL maintainer="Martin Helmich <typo3@martin-helmich.de>"

RUN sed -i s@/deb.debian.org/@/mirrors.163.com/@g /etc/apt/sources.list 


# Install TYPO3
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
		locales \
# Configure PHP
        libxml2-dev libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        zlib1g-dev \
# Install required 3rd party tools
        graphicsmagick && \
	pecl install APCu-5.1.17; \
	pecl install memcached-3.1.3; \
	pecl install redis-4.3.0; \
	docker-php-ext-enable \
		apcu \
		memcached \
		redis \
	; \
# Configure extensions
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) mysqli soap gd zip opcache intl && \
    echo 'always_populate_raw_post_data = -1\nmax_execution_time = 240\nmax_input_vars = 1500\nupload_max_filesize = 32M\npost_max_size = 32M' > /usr/local/etc/php/conf.d/typo3.ini && \
# Configure Apache as needed
    a2enmod rewrite && \
    apt-get clean && \
    apt-get -y purge \
        libxml2-dev libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/* /usr/src/*

	ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen
ENV LANG zh_CN.UTF-8  
ENV LANGUAGE zh_CN.UTF-8  
ENV LC_ALL zh_CN.UTF-8 

# Configure volumes
VOLUME /var/www/html/
