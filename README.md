## elasticsearch Dockerfile

[![Docker Hub](https://img.shields.io/badge/docker-swcc%2Fdocker--elasticsearch-blue.svg?style=flat)](https://registry.hub.docker.com/u/swcc/docker-elasticsearch/)

This repository contains the **Dockerfile** and the configuration files of [ElasticSearch](http://www.elasticsearch.org/) for [Docker](https://www.docker.com/).

### Base Docker Image

* [phusion/baseimage](https://github.com/phusion/baseimage-docker), the *minimal Ubuntu base image modified for Docker-friendliness*

### Installation

`docker pull swcc/docker-elasticsearch .`

or build it yourself:

`docker build -t swcc/docker-elasticsearch .`

### Usage

To run a single ES node, simply run a container with this image:

`docker run swcc/docker-elasticsearch`

You can now use your ES node via it's IP address. E.g. `http://172.17.0.X:9200`

### Customization

#### Expose the ES port

`docker run -p 9200:9200 swcc/docker-elasticsearch`

So you can directly access your ES node via `http://localhost:9200/`

#### Launch an ES cluster

Run two nodes by passing the same `ES_CLUSTER_NAME` environment variable like this:

`docker run -p 9200:9200 -e ES_CLUSTER_NAME=es-cluster  swcc/docker-elasticsearch`

`docker run -p 9201:9200 -e ES_CLUSTER_NAME=es-cluster  swcc/docker-elasticsearch`

#### Install the ES head plugin

Simply add the `ES_HEAD_PLUGIN=true` enviroment variable when running your ES node. This will install the [elasticsearch-head](http://mobz.github.io/elasticsearch-head/) plugin.

