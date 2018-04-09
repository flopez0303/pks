#!/bin/bash
date >>/home/ubuntu/startup-cluster.log
while true; do
    results=$(/usr/local/bin/pks login -a pks.corp.local  -u eval  -p VMware1! -k 2>&1 | awk '{print $1;}')
    if [ "${results:1:3}" == 'API' ] 
    then 
       break
    else
       sleep 30
       echo sleep  >> /home/ubuntu/startup-cluster.log
    fi
done


results=$(/usr/local/bin/pks list-clusters  |grep my-cluster |awk '{print $1;}')
if [ "${results:0:10}" == 'my-cluster' ]
then
   echo My cluster Already Created >> /home/ubuntu/startup-cluster.log
else
   echo My cluster does not exist >> /home/ubuntu/startup-cluster.log
   $(/usr/local/bin/pks create-cluster  my-cluster -e 10.40.14.34 -p small -n 2  >> /home/ubuntu/startup-cluster.log)
fi

date >>/home/ubuntu/startup-cluster.log
