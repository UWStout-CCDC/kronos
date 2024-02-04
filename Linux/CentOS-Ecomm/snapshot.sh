# Check if the user is root
if [ $(id -u) -ne 0 ]; then
    echo "You must be root to run this script."
    exit 1
fi

# check if docker is installed if not install it and start the service
if ! [ -x "$(command -v docker)" ]; then
    echo "Docker is not installed, installing..."
    yum install -y yum-utils
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum install -y docker-ce docker-ce-cli containerd.io
    systemctl start docker
    systemctl enable docker
fi

# make directory for the dockerfile
mkdir -p /opt/ecomm
cd /opt/ecomm

# create the dockerfile
cat <<EOF > Dockerfile
FROM alpine:latest

# Install mariadb server, and apache, and php 8.3
RUN apk update && apk add mariadb mariadb-client apache2 php8 php8-apache2 php8-mysqli php8-json php8-openssl php8-curl php8-zlib php8-xml php8-phar php8-intl php8-dom php8-xmlreader php8-ctype php8-session php8-mbstring php8-gd php8-tokenizer php8-fileinfo php8-xmlwriter php8-simplexml php8-iconv php8-pdo php8-pdo_mysql php8-openssl php8-session php8-tokenizer php8-fileinfo php8-xmlwriter php8-simplexml php8-iconv php8-pdo php8-pdo_mysql php8-openssl php8-session php8-tokenizer php8-fileinfo php8-xmlwriter php8-simplexml php8-iconv php8-pdo php8-pdo_mysql php8-openssl php8-session php8-tokenizer php8-fileinfo php8-xmlwriter php8-simplexml php8-iconv php8-pdo php8-pdo_mysql php8-openssl php8-session php8-tokenizer php8-fileinfo php8-xmlwriter php8-simplexml php8-iconv php8-pdo php8-pdo_mysql php8-openssl php8-session php8-tokenizer php8-fileinfo php8-xmlwriter php8-simplexml php8-iconv php8-pdo php8-pdo_mysql php8-openssl php8-session php8-tokenizer php8-fileinfo php8-xmlwriter php8-simplexml php8-iconv php8-pdo php8-pdo_mysql php8-openssl php8-session php8-tokenizer php8-fileinfo php8-xmlwriter php8-simplexml php8-iconv php8-pdo php8-pdo_mysql php8-openssl php8-session php8-tokenizer php8-fileinfo php8-xmlwriter php8-simplexml php8-iconv php8-pdo php8-pdo_mysql php8-openssl php8-session php8-tokenizer php8-fileinfo php8-xmlwriter php8-simplexml php8-iconv php8-pdo php8-pdo_mysql php8-openssl php8-session php8-tokenizer php8-fileinfo php8-xmlwriter php8-simplexml php8-iconv php8-pdo php8-pdo_mysql php8-openssl php8-session php8-tokenizer php8-fileinfo php8-xmlwriter php8-simplexml

# Uninstall all text editors alpine comes with
RUN apk del nano vim emacs alpine-pico

# Uninstall all compilers alpine comes with
RUN apk del gcc g++ make

# Uninstall all documentation alpine comes with
RUN apk del

# Uninstall all shells alpine comes with
RUN apk del bash sh zsh

# Uninstall curl / wget
RUN apk del curl wget

# Uninstall apk
RUN apk --purge del apk-tools


# Set the working directory
WORKDIR /var/www/html/prestashop

# Copy the prestashop files
COPY /var/www/html/prestashop /var/www/html/prestashop

# Copy over the apache configuration file
COPY /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf

# Copy over the php configuration file
COPY /etc/php7/php.ini /etc/php7/php.ini

# Copy over the sql database
COPY /var/lib/mysql /var/lib/mysql
EOF

# build the image
docker build -t ecomm .

# Disable the current apache server and sql server
systemctl stop httpd
systemctl stop mariadb

# run the image
docker run -d -p 80:80 ecomm