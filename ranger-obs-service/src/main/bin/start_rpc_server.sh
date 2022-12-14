#!/bin/sh

export LANG=en_US.utf8

cur_dir=$(cd `dirname $0`;pwd)
dir=$(dirname $cur_dir)
pidFile=${ENV_INSTANCE_PID_FILE}

# class path地址
cp_path=${dir}:${dir}/conf:${dir}/lib/*:${dir}/classes/*

if [ "$1" != "" ]; then
  cp_path=$1:${cp_path}
fi

export ranger_obs_service_config_dir=$1

nohup nice java ${GC_OPTS} -Dfile.encoding=UTF-8 -Djava.security.krb5.conf=/etc/krb5.conf -cp "$cp_path" org.apache.ranger.obs.server.Server 2>&1 < /dev/null &

echo $! >$pidFile
