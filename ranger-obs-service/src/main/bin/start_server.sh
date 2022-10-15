#!/bin/sh

export LANG=en_US.utf8
#export JAVA_HOME=

export PATH=$PATH:$JAVA_HOME/bin

cur_dir=$(cd `dirname $0`;pwd)
dir=$(dirname $cur_dir)

# class path地址
cp_path=${dir}:${dir}/conf:${dir}/lib/*:${dir}/classes/*

native_path=/opt/cloudera/parcels/CDH-7.1.7-1.cdh7.1.7.p0.15945976/lib/hadoop/lib/native

# java.libray.path
java -Xms1024M -Xmx2048M -Dfile.encoding=UTF-8 -Djava.library.path=$native_path -Djava.security.krb5.conf=/etc/krb5.conf -cp "$cp_path" org.apache.ranger.obs.server.Server
