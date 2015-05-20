#!/bin/bash
. "$(dirname "$0")"/init.sh

cd ~/Development/Servers/jetty-6.0.0beta5-1
java5.sh -agentlib:jdwp=transport=dt_socket,address=8000,server=y,suspend=n -jar start.jar etc/jetty.xml
