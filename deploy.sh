#!/usr/bin/env bash

set -eu

DB_CONTAINER_NAME='odkdb'
AGGREGATE_CONTAINER_NAME='aggregate'

if [ -f ./secrets.sh ]; then
  source ./secrets.sh
fi

if [ $(docker ps -aq --filter "name=$DB_CONTAINER_NAME") ]; then
  docker stop $DB_CONTAINER_NAME && docker rm $DB_CONTAINER_NAME
fi
docker pull mysql:5.7

if [ $(docker ps -aq --filter "name=$AGGREGATE_CONTAINER_NAME") ]; then
  docker stop $AGGREGATE_CONTAINER_NAME && docker rm $AGGREGATE_CONTAINER_NAME
fi
docker pull kharatsa/odkaggregate:latest

if [ $(docker images -q --filter "dangling=true") ]; then
  docker rmi $(docker images -q --filter "dangling=true")
fi

ODK_DB_HOST_PATH=$ODK_DB_HOST_PATH
if [ $ODK_DB_HOST_PATH == "" ]; then
  ODK_DB_HOST_PATH="~/data"
fi

if [ ! -d $ODK_DB_HOST_PATH ]; then
  echo "Creating host database storage path - $ODK_DB_HOST_PATH"
  mkdir -p $ODK_DB_HOST_PATH
fi

docker run -d --name=$DB_CONTAINER_NAME \
  -v $ODK_DB_HOST_PATH:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
  -e MYSQL_DATABASE=$MYSQL_DATABASE \
  -e MYSQL_USER=$MYSQL_USER \
  -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
  mysql:5.7

docker run -d --name=$AGGREGATE_CONTAINER_NAME \
  --link $DB_CONTAINER_NAME \
  --restart on-failure:10 \
  -p 8080:8080 \
  -e DB_CONTAINER_NAME=$DB_CONTAINER_NAME \
  -e MYSQL_DATABASE=$MYSQL_DATABASE \
  -e MYSQL_USER=$MYSQL_USER \
  -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
  -e ODK_PORT=$ODK_PORT \
  -e ODK_PORT_SECURE=$ODK_PORT_SECURE \
  -e ODK_HOSTNAME=$ODK_HOSTNAME \
  kharatsa/odkaggregate:latest