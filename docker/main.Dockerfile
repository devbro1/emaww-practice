#command to build:
#docker build --tag test1:v1.1 .
#make sure to delete from docker desktop before building

FROM amazonlinux:2.0.20211223.0

#open ports for access from host
# EXPOSE 5432:5432
# EXPOSE 80:80
# EXPOSE 8000:8000

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

#run commands to update packages, install php, nginx, and run respective systems
RUN amazon-linux-extras enable nginx1=latest
RUN amazon-linux-extras enable vim=latest
RUN amazon-linux-extras enable epel=latest
RUN amazon-linux-extras enable postgresql13=latest
RUN amazon-linux-extras enable php8.0=latest
RUN amazon-linux-extras install epel -y
RUN yum clean all && yum update -y && yum autoremove -y && yum clean all
# RUN yum clean all && yum autoremove -y && yum clean all
RUN yum -y install php \
    nginx postgresql\
    wget zip unzip make rsync git vim bash-completion tar
RUN yum install -y php-cli php-fpm php-pgsql php-mbstring php-xml php-json php-pdo php-pecl-zip php-pecl-redis

WORKDIR /root


ENV NVM_DIR /root/.nvm
ENV NODE_VERSION 16.9.1
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default \
    && npm install -g yarn

#php
# RUN mkdir /run/php-fpm/
#RUN sed -i 's/\r$//' /root/start.sh
RUN sed -i 's/^display_errors = Off$/display_errors = On/' /etc/php.ini
RUN sed -i 's/^display_startup_errors = Off$/display_startup_errors = On/' /etc/php.ini
RUN sed -i 's/^upload_max_filesize = .*$/upload_max_filesize = 20M/' /etc/php.ini
RUN sed -i 's/^memory_limit = .*$/memory_limit = 3000M/' /etc/php.ini

WORKDIR /root/php-composer/
RUN wget https://getcomposer.org/installer -O composer-installer.php
RUN php composer-installer.php --filename=composer --install-dir=/usr/local/bin 
RUN composer global require laravel/installer
RUN export PATH=$PATH:/root/.composer/vendor/bin

RUN git config --global user.email "farzadk@gmail.com"
RUN git config --global user.name "Farzad Meow Khalafi"
RUN git config --global core.eol lf
RUN git config --global core.autocrlf false

WORKDIR /root/source_code
COPY ./* .
COPY ./docker/git/ ./.git/
RUN chmod -R 777 .git/hooks/

COPY docker/init_script.sh /root/init_script.sh
CMD ["/root/init_script.sh"]
