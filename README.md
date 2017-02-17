# Sidekiq Queue Zabbix
This mini project use for sidekiq queue monitoring on zabbix. It supports showing graphs and alerting when queue size is higher than one specified limit

## Setup:
 - Setup redis-cli
 - Setup zabbix-agent

#  Import template
Import zabbix_template.xml and custom discovery keys (change namespace, redis host, redis port) on zabbix ( Zabbix Screen -> Config -> Templates -> Choose imported templates -> Discovery Rules )
