#!/bin/sh
# Inspired by:
# /etc/init.d/elasticsearch -- startup script for Elasticsearch
#
# Written by Miquel van Smoorenburg <miquels@cistron.nl>.
# Modified for Debian GNU/Linux	by Ian Murdock <imurdock@gnu.ai.mit.edu>.
# Modified for Tomcat by Stefan Gybas <sgybas@debian.org>.
# Modified for Tomcat6 by Thierry Carrez <thierry.carrez@ubuntu.com>.
# Additional improvements by Jason Brittain <jason.brittain@mulesoft.com>.
# Modified by Nicolas Huray for Elasticsearch <nicolas.huray@gmail.com>.

PATH=/bin:/usr/bin:/sbin:/usr/sbin
NAME=elasticsearch
DESC="Elasticsearch Server"
DEFAULT=/etc/default/$NAME

if [ `id -u` -ne 0 ]; then
        echo "You need root privileges to run this script"
        exit 1
fi


. /lib/lsb/init-functions

if [ -r /etc/default/rcS ]; then
        . /etc/default/rcS
fi


# The following variables can be overwritten in $DEFAULT

# Run Elasticsearch as this user ID and group ID
ES_USER=elasticsearch
ES_GROUP=elasticsearch

# The first existing directory is used for JAVA_HOME (if JAVA_HOME is not defined in $DEFAULT)
JDK_DIRS="/usr/lib/jvm/jdk-7-oracle-x64 /usr/lib/jvm/java-7-oracle /usr/lib/jvm/java-7-openjdk /usr/lib/jvm/java-7-openjdk-amd64/ /usr/lib/jvm/java-7-openjdk-armhf /usr/lib/jvm/java-7-openjdk-i386/ /usr/lib/jvm/default-java"

# Look for the right JVM to use
for jdir in $JDK_DIRS; do
    if [ -r "$jdir/bin/java" -a -z "${JAVA_HOME}" ]; then
        JAVA_HOME="$jdir"
    fi
done
export JAVA_HOME

# Directory where the Elasticsearch binary distribution resides
ES_HOME=/usr/share/$NAME

# Heap size defaults to 256m min, 1g max
# Set ES_HEAP_SIZE to 50% of available RAM, but no more than 31g
#ES_HEAP_SIZE=2g

# Heap new generation
#ES_HEAP_NEWSIZE=

# max direct memory
#ES_DIRECT_SIZE=

# Additional Java OPTS
#ES_JAVA_OPTS=

# Maximum number of open files
MAX_OPEN_FILES=65535

# Maximum amount of locked memory
#MAX_LOCKED_MEMORY=

# Elasticsearch log directory
LOG_DIR=/var/log/$NAME

# Elasticsearch data directory
DATA_DIR=/data

# Elasticsearch work directory
WORK_DIR=/tmp/$NAME

# Elasticsearch configuration directory
CONF_DIR=/etc/$NAME

# Elasticsearch configuration file (elasticsearch.yml)
CONF_FILE=$CONF_DIR/elasticsearch.yml

# Maximum number of VMA (Virtual Memory Areas) a process can own
MAX_MAP_COUNT=262144

# End of variables that can be overwritten in $DEFAULT

# overwrite settings from default file
if [ -f "$DEFAULT" ]; then
        . "$DEFAULT"
fi

# Define other required variables
PID_FILE=/var/run/$NAME.pid
DAEMON=$ES_HOME/bin/elasticsearch
DAEMON_OPTS="-p $PID_FILE --default.config=$CONF_FILE --default.path.home=$ES_HOME --default.path.logs=$LOG_DIR --default.path.data=$DATA_DIR --default.path.work=$WORK_DIR --default.path.conf=$CONF_DIR"

export ES_HEAP_SIZE
export ES_HEAP_NEWSIZE
export ES_DIRECT_SIZE
export ES_JAVA_OPTS

# Check DAEMON exists
test -x $DAEMON || exit 0

checkJava() {
        if [ -x "$JAVA_HOME/bin/java" ]; then
                JAVA="$JAVA_HOME/bin/java"
        else
                JAVA=`which java`
        fi

        if [ ! -x "$JAVA" ]; then
                echo "Could not find any executable java binary. Please install java in your PATH or set JAVA_HOME"
                exit 1
        fi
}

checkJava

if [ -n "$MAX_LOCKED_MEMORY" -a -z "$ES_HEAP_SIZE" ]; then
    log_failure_msg "MAX_LOCKED_MEMORY is set - ES_HEAP_SIZE must also be set"
    exit 1
fi

log_daemon_msg "Starting $DESC"

pid=`pidofproc -p $PID_FILE elasticsearch`
if [ -n "$pid" ] ; then
    log_begin_msg "Already running."
    log_end_msg 0
    exit 0
fi

# Prepare environment
mkdir -p "$LOG_DIR" "$DATA_DIR" "$WORK_DIR" && chown "$ES_USER":"$ES_GROUP" "$LOG_DIR" "$DATA_DIR" "$WORK_DIR"
touch "$PID_FILE" && chown "$ES_USER":"$ES_GROUP" "$PID_FILE"

if [ -n "$MAX_OPEN_FILES" ]; then
    ulimit -n $MAX_OPEN_FILES
fi

if [ -n "$MAX_LOCKED_MEMORY" ]; then
    ulimit -l $MAX_LOCKED_MEMORY
fi

if [ -n "$MAX_MAP_COUNT" ]; then
    sysctl -q -w vm.max_map_count=$MAX_MAP_COUNT
fi

# Start ElasticSearch
exec /sbin/setuser "$ES_USER" $DAEMON $DAEMON_OPTS
