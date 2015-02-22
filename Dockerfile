FROM phusion/baseimage 

RUN apt-get update && \ 
apt-get install \
	wget curl \
	apt-transport-https \
	ca-certificates \
	nginx php5 php5-cli php5-fpm php5-mysql \
	php5-mcrypt php5-curl php5-gd php5-imagick \
-y

RUN curl https://repo.varnish-cache.org/debian/GPG-key.txt --insecure | apt-key add -
RUN echo "deb https://repo.varnish-cache.org/debian/ wheezy varnish-4.0" >> /etc/apt/sources.list.d/varnish-cache.list
RUN apt-get update && apt-get install varnish -y
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 80

ADD ./build/ /

ADD ./src/varnish/ /etc/varnish/
