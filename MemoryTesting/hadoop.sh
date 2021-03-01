#!/usr/bin/env bash

/opt/hadoop2.7/sbin/$1-dfs.sh; echo 8088; 
/opt/hadoop2.7/sbin/$1-yarn.sh; echo 50080;
/opt/hadoop2.7/sbin/mr-jobhistory-daemon.sh $1 historyserver; echo 19888;
