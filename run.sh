#!/bin/bash

set -eu

if [ ! -f /finished-setup ]; then
  echo "---- Running Tomcat & ODK Aggregate Setup ---"
  apt-get update && apt-get install default-jdk -y --no-install-recommends > /dev/null 2>&1

  echo "---- Updating ODK Aggregate configuration ----"
  mkdir -p /odktmp
  mkdir -p /odksettingstmp
  pushd /odktmp
  jar -xvf /ODKAggregate.war > /dev/null 2>&1
  pushd /odksettingstmp
  jar -xvf /odktmp/WEB-INF/lib/ODKAggregate-settings.jar > /dev/null 2>&1

  echo "---- Environment Variables ----"
  echo "ODK_PORT=$ODK_PORT"
  echo "ODK_PORT_SECURE=$ODK_PORT_SECURE"
  echo "ODK_HOSTNAME=$ODK_HOSTNAME"
  echo "ODK_ADMIN_USER=$ODK_ADMIN_USER"
  echo "ODK_ADMIN_USERNAME=$ODK_ADMIN_USERNAME"
  echo "ODK_AUTH_REALM=$ODK_AUTH_REALM"
  echo "MYSQL_HOSTNAME=$MYSQL_HOSTNAME"
  echo "MYSQL_DATABASE=$MYSQL_DATABASE"
  echo "MYSQL_USER=$MYSQL_USER"
  echo "CATALINA_HOME=$CATALINA_HOME"

  echo "---- Modifying ODK Aggregate security.properties ----"
  echo "Updating security.server.port"
  sed -i -E "s|^(security.server.port=)([0-9]+)|\1$ODK_PORT|gm" security.properties
  echo "Updating security.server.securePort"
  sed -i -E "s|^(security.server.securePort=)([0-9]+)|\1$ODK_PORT_SECURE|gm" security.properties
  echo "Updating security.server.hostname"
  sed -i -E "s|^(security.server.hostname=)([A-Za-z\.0-9]+)|\1$ODK_HOSTNAME|gm" security.properties
  echo "Updating security.server.superUser"
  sed -i -E "s|^(security.server.superUser=).*|\1$ODK_ADMIN_USER|gm" security.properties
  echo "Updating security.server.superUserUsername"
  sed -i -E "s|^(security.server.superUserUsername=).*|\1$ODK_ADMIN_USERNAME|gm" security.properties
  echo "Updating security.server.realm.realmString"
  sed -i -E "s|^(security.server.realm.realmString=).*|\1$ODK_AUTH_REALM|gm" security.properties
  cp security.properties ~/

  echo "---- Modifying ODK Aggregate jdbc.properties ----"
  sed -i -E "s|^(jdbc.url=jdbc:mysql://).+(\?autoDeserialize=true)|\1$MYSQL_HOSTNAME/$MYSQL_DATABASE\2|gm" jdbc.properties
  sed -i -E "s|^(jdbc.url=jdbc:mysql:///)(.+)(\?autoDeserialize=true)|\1""\3|gm" jdbc.properties
  sed -i -E "s|^(jdbc.schema=).*|\1$MYSQL_DATABASE|gm" jdbc.properties
  sed -i -E "s|^(jdbc.username=).*|\1$MYSQL_USER|gm" jdbc.properties
  sed -i -E "s|^(jdbc.password=).*|\1$MYSQL_PASSWORD|gm" jdbc.properties
  cp jdbc.properties ~/

  echo "---- Rebuilding ODKAggregate-settings.jar ----"
  jar cvf /ODKAggregate-settings.jar ./* > /dev/null 2>&1
  popd
  rm -rf /odksettingstmp
  mv -f /ODKAggregate-settings.jar /odktmp/WEB-INF/lib/ODKAggregate-settings.jar
  echo "---- Rebuilding ODKAggregate.war ----"
  jar cvf /ODKAggregate.war ./* > /dev/null 2>&1
  popd
  rm -rf /odksettingstmp

  echo "---- Deploying ODKAggregate.war to $CATALINA_HOME/webapps/ROOT.war ----"
  rm -rf $CATALINA_HOME/webapps
  [ -d /var/lib/tomcat6/webapps ] || mkdir -p $CATALINA_HOME/webapps
  cp /ODKAggregate.war $CATALINA_HOME/webapps/ROOT.war

  apt-get purge default-jdk -y > /dev/null 2>&1

  touch /finished-setup

  echo "---- Tomcat & ODK Aggregate Setup Complete ---"
fi

exec $CATALINA_HOME/bin/catalina.sh run "$@"
