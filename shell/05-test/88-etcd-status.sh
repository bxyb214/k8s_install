#!/bin/bash
# author: felix-zh
# e-mail: faer615@gmail.com

# import global env
ENVFILE=./00-env.sh
if [ -f $ENVFILE ];then
  . $ENVFILE
else
echo -e "\033[40;31m ############################# \033[5m"
echo -e "\033[40;31m ##   $ENVFILE not found!   ## \033[0m"
echo -e "\033[40;31m ############################# \033[0m"
exit 
fi

export ETCDCTL_API=3 

for ip in ${NODE_IPS}; do
  etcdctl \
  --endpoints=https://${ip}:2379  \
  --ca-file=/etc/kubernetes/ssl/ca.pem \
  --cert-file=/etc/kubernetes/ssl/kubernetes.pem \
  --key-file=/etc/kubernetes/ssl/kubernetes-key.pem \
  endpoint health
done
