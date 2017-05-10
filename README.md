# Sidekiq Queue Zabbix
This mini project use for sidekiq queue monitoring on zabbix. It supports showing graphs and alerting when queue size is higher than one specified limit

## Setup:
 - Setup redis-cli
 - Setup zabbix-agent

## Import userparams for zabbix-agent

 - Copy userparam_sidekiq_queue.conf to your zabbix-agent config dir.
 - Copy redis-queue-discovery.sh to external scripts dir ( view userparam_sidekiq_queue.conf to see full path). You can export REDIS_HOME variable if you need specify REDIS PATH. Redis will load on $REDIS_HOME/src/redis-cli. If you don't specify REDIS_HOME variable, the script will call redis-cli
 - Add execute permission by `chmod +x redis-queue-discovery.sh`
 - Restart you zabbix-agent service

 # Import template
  Import zabbix_template.xml  to zabbix ( Zabbix Screen -> Config -> Templates -> Choose imported templates ).

 # Add Template to host

 ## Setup Macros for host
   Add below macros on Host Macros:
   - {$SIDEKIQ_DB}: the db number
   - {$SIDEKIQ_REDIS_HOST}: the redis host
   - {$SIDEKIQ_REDIS_PORT}: the redis port
   - {$SIDEKIQ_NS}: the sidekiq namespace. The value can be `all` to list all, or `value1 value2` or empty.

 ## Add Template Sidekiq Queue Monitor
 On  Zabbix Screen -> Config -> Host. Click redis host which contains sidekiq data.
 Click Templates Menu, add `Template Sidekiq Queue Monitor` and `Update`
