#!/bin/sh
### BEGIN INIT INFO
# Provides:          Dataloop Agent
# Required-Start:    $local_fs $network
# Required-Stop:     $local_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       Dataloop Agent
### END INIT INFO
API_KEY={{ dataloop_api_key }}
SERVER=https://www.dataloop.io
SCRIPT="/usr/local/bin/dataloop-lin-agent --api-key $API_KEY --server $SERVER"
RUNAS=root

PIDFILE=/var/run/dataloop-agent.pid
LOGFILE=/var/log/dataloop/agent.log

start() {
  if [ -f /var/run/$PIDNAME ] && kill -0 $(cat /var/run/$PIDNAME); then
    echo 'Service already running' >&2
    return 1
  fi
  echo 'Starting service…' >&2
  local CMD="$SCRIPT &> \"$LOGFILE\" & echo \$!"
  su -c "$CMD" $RUNAS > "$PIDFILE"
  echo 'Service started' >&2
}

stop() {
  if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
    echo 'Service not running' >&2
    return 1
  fi
  echo 'Stopping service…' >&2

  su -c "$SCRIPT --deregister" $RUNAS

  if [ $? -ne 0 ]; then
    echo "failed! "
  else
    echo "success"
  fi

  echo "dataloop agent stopped"
  kill -15 $(cat "$PIDFILE") && rm -f "$PIDFILE"
  echo 'Service stopped' >&2
}

uninstall() {
  echo -n "Are you really sure you want to uninstall this service? That cannot be undone. [yes|No] "
  local SURE
  read SURE
  if [ "$SURE" = "yes" ]; then
    stop
    rm -f "$PIDFILE"
    echo "Notice: log file is not be removed: '$LOGFILE'" >&2
    update-rc.d -f dataloop-agent remove
    rm -fr /opt/dataloop
    rm -f /usr/local/bin/dataloop-lin-agent
    rm -f "$0"
  fi
}

status() {
  case "$(pidof dataloop-lin-agent | wc -w)" in
    0) echo 'Service is stopped' >&2
       exit 3
       ;;
    *) echo 'Service is running' >&2
       ;;
  esac
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  uninstall)
    uninstall
    ;;
  restart)
    stop
    start
    ;;
  status)
    status
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|uninstall}"
esac
