FROM phusion/baseimage:latest

MAINTAINER Paul B. <paul+swcc@bonaud.fr>

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

# Java Installation
RUN \
  echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update -qqy && \
  apt-get install -qqy oracle-java7-installer && \
  rm -rf /var/cache/oracle-jdk7-installer
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

# ElasticSearch Installation
RUN wget -qO - https://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
RUN add-apt-repository "deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main"
RUN apt-get update && apt-get install elasticsearch
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD build/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
ADD build/logging.yml /etc/elasticsearch/logging.yml

RUN mkdir /etc/service/elasticsearch
ADD build/elasticsearch.sh /etc/service/elasticsearch/run
RUN chmod +x /etc/service/elasticsearch/run

# Setup scripts
ADD build/setup.sh /etc/my_init.d/elasticsearch-setup.sh
RUN chmod +x /etc/my_init.d/elasticsearch-setup.sh

WORKDIR /data
VOLUME ["/data"]
EXPOSE 9200 9300

CMD ["/sbin/my_init"]
# End Installation