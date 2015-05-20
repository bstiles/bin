#!/bin/bash

# CLASSPATH_FILE=/Users/bstiles/.java/classpath

# if [ -f "$CLASSPATH_FILE" ]; then
#     . "$CLASSPATH_FILE"
#     echo "*** Using $CLASSPATH_FILE to extend CLASSPATH. ***"
# fi

JAVASCRIPT_VERSION=170
exec java -Xmx512m -Dnet.bstiles.shell=true -classpath "$CLASSPATH:/Users/bstiles/Development/Library/Rhino/Versions/1.7r3/rhino1_7R3/js.jar" org.mozilla.javascript.tools.shell.Main -version $JAVASCRIPT_VERSION "$@"

#exec mvn -f ~/.java/projects/rhino-exec/pom.xml -DMAVEN_OPTS=-Xmx512m -Dnet.bstiles.shell=true exec:java -Dexec.args="-version $JAVASCRIPT_VERSION -e load(\\\"/Users/bstiles/.java/javascript/util.js\\\") -f -"
#exec mvn -f ~/.java/projects/rhino-exec/pom-jackrabbit-2.0.xml -DMAVEN_OPTS=-Xmx512m -Dnet.bstiles.shell=true exec:java -Dexec.args="-version $JAVASCRIPT_VERSION -e load(\\\"/Users/bstiles/.java/javascript/util.js\\\") -f -"

#exec java -Xmx512m -Dnet.bstiles.shell=true -classpath "$CLASSPATH:/Users/bstiles/.m2/repository/rhino/js/1.7R2/js-1.7R2.jar" org.mozilla.javascript.tools.shell.Main -version $JAVASCRIPT_VERSION "$@"
