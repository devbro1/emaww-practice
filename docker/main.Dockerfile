#command to build:
#docker build --tag test1:v1.1 .
#make sure to delete from docker desktop before building

FROM php:7.4.27-cli

#change default shell from sh to bash
SHELL ["/bin/bash", "-c"]

#change timezone to eastern/toronto
RUN ln -sf /usr/share/zoneinfo/America/Toronto /etc/localtime

COPY docker/bashrc /root/.bashrc
#set SSH keys
COPY docker/ssh /root/.ssh/
RUN chmod 600 /root/.ssh/id_rsa
RUN chmod 644 /root/.ssh/id_rsa.pub
RUN chmod 644 /root/.ssh/known_hosts



#change folder to /
WORKDIR /

RUN apt-get update && apt-get install -y wget zip unzip make rsync git vim bash-completion tar
RUN pecl install redis-5.1.1 \
    && docker-php-ext-enable redis



# WORKDIR /root
# ENV NVM_DIR /root/.nvm
# ENV NODE_VERSION 16.9.1
# RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash \
#     && . $NVM_DIR/nvm.sh \
#     && nvm install $NODE_VERSION \
#     && nvm alias default $NODE_VERSION \
#     && nvm use default \
#     && npm install -g yarn

#php
# RUN mkdir /run/php-fpm/
#RUN sed -i 's/\r$//' /root/start.sh
# RUN sed -i 's/^display_errors = Off$/display_errors = On/' /etc/php.ini
# RUN sed -i 's/^display_startup_errors = Off$/display_startup_errors = On/' /etc/php.ini
# RUN sed -i 's/^upload_max_filesize = .*$/upload_max_filesize = 20M/' /etc/php.ini
# RUN sed -i 's/^memory_limit = .*$/memory_limit = 3000M/' /etc/php.ini

WORKDIR /root/php-composer/
RUN wget https://getcomposer.org/installer -O composer-installer.php
RUN php composer-installer.php --filename=composer --install-dir=/usr/local/bin 
RUN composer global require laravel/installer
RUN export PATH=$PATH:/root/.composer/vendor/bin

RUN git config --global user.email "farzadk@gmail.com"
RUN git config --global user.name "Farzad Meow Khalafi"
RUN git config --global core.eol lf
RUN git config --global core.autocrlf false

COPY . /usr/src/myapp
WORKDIR /usr/src/myapp
RUN composer i
RUN composer require phpunit/phpunit
RUN cat composer.json
CMD [ "php", "./start.php" , "-v", "./config.xml" ]
#CMD [ "./vendor/bin/phpunit", "StartTest.php"]

