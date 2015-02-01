#!/bin/sh

if [ -n "$ES_HEAD_PLUGIN" ]; then
    /usr/share/elasticsearch/bin/plugin -install mobz/elasticsearch-head
fi

if [ -n "$ES_CLUSTER_NAME" ]; then
    sed 's/.*cluster.name.*/cluster.name: '"$ES_CLUSTER_NAME"'/' /etc/elasticsearch/elasticsearch.yml > /etc/elasticsearch/elasticsearch.yml.cluster
    mv /etc/elasticsearch/elasticsearch.yml.cluster /etc/elasticsearch/elasticsearch.yml
fi

exit 0
