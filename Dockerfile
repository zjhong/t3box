FROM php:7.2-apache
LABEL maintainer="zjhong@gmail.com"

# Install PHP extensions and PECL modules.
RUN buildDeps=" \
        default-libmysqlclient-dev \
        libbz2-dev \
        libmemcached-dev \
        libsasl2-dev \
    " \
    runtimeDeps=" \
        curl \
        git \
        libfreetype6-dev \
        libicu-dev \
        libjpeg-dev \
        libldap2-dev \
        libmemcachedutil2 \
        libpng-dev \
        libpq-dev \
        libxml2-dev \
    " \
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y $buildDeps $runtimeDeps \
	&& apt-get install -y --no-install-recommends wget locales graphicsmagick \
    && docker-php-ext-install bcmath bz2 calendar iconv intl mbstring mysqli opcache pdo_mysql pdo_pgsql pgsql soap zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install ldap \
    && docker-php-ext-install exif \
    && pecl install memcached redis apcu \
    && docker-php-ext-enable memcached.so redis.so apcu.so\
	&&     echo 'always_populate_raw_post_data = -1\nmax_execution_time = 240\nmax_input_vars = 1500\nupload_max_filesize = 32M\npost_max_size = 32M' > /usr/local/etc/php/conf.d/typo3.ini \
    && apt-get purge -y --auto-remove $buildDeps \
    && rm -r /var/lib/apt/lists/* \
	&& apt-get clean \
    && a2enmod rewrite
ENV TZ=Asia/Shanghai
# Enable mod_expires
RUN cp /etc/apache2/mods-available/expires.load /etc/apache2/mods-enabled/
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen
ENV LANG zh_CN.UTF-8  
ENV LANGUAGE zh_CN.UTF-8  
ENV LC_ALL zh_CN.UTF-8 

# Configure volumes
VOLUME /var/www/html/
