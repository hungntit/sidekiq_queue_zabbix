#!/bin/bash
#@Author: hungnt. Email: hungnt.it@gmail.com
# This script use for
namespace=
redishost=
redisport=
queue=
redisdb=0
REDIS_CLI="redis-cli"
if [ "$REDIS_CLI_PATH" == "" ];then
  if [ "$REDIS_HOME" == "" ];then
    if [ -f /usr/local/sbin/redis-cli ];then
      REDIS_CLI="/usr/local/sbin/redis-cli"
    else
      if [ -f /usr/bin/redis-cli ];then
        REDIS_CLI="/usr/bin/redis-cli"
      else
        if [ -f /usr/local/bin/redis-cli ];then
          REDIS_CLI="/usr/local/bin/redis-cli"
        else
          REDIS_CLI="redis-cli"
        fi
      fi
    fi
  else
    REDIS_CLI="$REDIS_HOME/src/redis-cli"
  fi
else
  REDIS_CLI="$REDIS_CLI_PATH"
fi
function help() {
cat <<EOF
@Author: hungnt
@Email: hungnt.it@gmail.com
Usage: $0 CMD [OPTION]
CMD:
  discovery:show all queues of namespace. Usage: $0 discovery [-h redishost] [ -p redisport] -n namespace
  queuesize:show size of queue. Usage: $0 queuesize  [-h redishost] [ -p redisport]  -n namespace -q queuename
  ?|--help: show usage
OPTIONS:
  -d|--db: database number
  -h|--redis-host: redis host
  -p|--redis-port: redis port
  -n|--namespace: namespace of sidekiq. -n all for all discovery all queues and anything else for specified namespace. Example -n rail , -n default
  -q|--queue: queue name
EOF
}

#list sidekiq namespace
function list_all_namespaces() {
  echo "keys *queues"|${REDIS_CLI_CMD}|awk '{
          if(match($1,":queues")){
             split($1,a,":queues");
             print a[1]
          }else if($1 == "queues") print "default"
  }'
}
function list_namespaces() {
  if [ "$namespace" == "all" ];then
    list_all_namespaces
  else
    if [ "$namespace" == "" ];then
      echo "default"
    else
      for i in $(echo $namespace | tr " " "\n"); do echo $i; done
    fi
  fi

}
function printDiscoveryLine() {
  local ns=$1
  local seperator=$2
  local queuesns=$ns:queues
  if [ "${ns}" == "default" ];then
    queuesns="queues"
    ns=""
  fi
  printf "$seperator"
  echo  "SMEMBERS ${queuesns}"|${REDIS_CLI_CMD}|awk -v namespace="${ns}"  '{if($1 != "" ) { printf "%s\t\t{\"{#SK_QUEUE}\":\"%s\", \"{#SK_NS}\":\"%s\"}",seperate,$1,namespace; seperate=",\n"}}'
}
#show all queues of sidekiq by namespace
function discovery() {
    local seperator=
		echo -e "{\n\t\"data\":["
    for tmpns in `list_namespaces`;do
      local ns=$tmpns
			printDiscoveryLine $ns $seperator
      seperator=",\n"
		done
		echo -e "\n\t]\n}"
}
#show size of queue in sidekiq
function queuesize() {
  if [ -x $queue ];then
	echo "queue name is wrong"
	return;
  fi
  local queuesns=$namespace:queue
  if [ -x $namespace ];then
       queuesns="queue"
  fi
  echo "llen ${queuesns}:${queue}"|${REDIS_CLI_CMD}|awk '{print $1}'
}
cmd=$1
shift
REDIS_CLI_CMD="$REDIS_CLI"
while [[ $# > 1 ]]
do
key="$1"
HAVE_VALUE=false
case $2 in
     -*);;
      *) HAVE_VALUE="true";;
esac
case $key in
    -h|--redis-host)
    if [ "$HAVE_VALUE" == "true" ];then
      redishost="$2"
      REDIS_CLI_CMD="${REDIS_CLI_CMD} -h ${redishost}"
      shift  # past argument
    fi
    ;;
    -p|--redis-port)
    if [ "$HAVE_VALUE" == "true" ];then
      redisport="$2"
      REDIS_CLI_CMD="${REDIS_CLI_CMD} -p ${redisport}"
      shift # past argument
    fi
    ;;
    -n|--namespace)
    if [ "$HAVE_VALUE" == "true" ];then
      namespace="$2"
      shift # past argument
    fi
    ;;
    -q|--queue)
    if [ "$HAVE_VALUE" == "true" ];then
      queue="$2"
      shift # past argument
    fi
    ;;
    -d|--db)
    if [ "$HAVE_VALUE" == "true" ];then
      redisdb="$2"
      shift # past argument
    fi
    ;;
    *)
    echo "option wrong. Type $0 -h to show usage"

    exit 404;
    ;;
esac
shift # past argument or value
done

REDIS_CLI_CMD="$REDIS_CLI -n ${redisdb}"
if [ ! -x ${redishost} ];then
  REDIS_CLI_CMD="${REDIS_CLI_CMD} -h ${redishost}"
fi
if [ ! -x ${redisport} ];then
  REDIS_CLI_CMD="${REDIS_CLI_CMD} -p ${redisport}"
fi

case $cmd in
  discovery)
	discovery $namespace
	#discovery $namespace >> /tmp/sidekiqmornitor.log
	;;
  queuesize)
	queuesize "$namespace" "$queue"
	;;
  \?|--help)
    help
    ;;
  *)
	echo "command is wrong. Type $0 --help to show usage"
	exit 1;
	;;
esac
