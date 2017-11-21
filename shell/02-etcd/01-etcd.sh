#!/bin/bash -x
# author: felix-zh
# e-mail: faer615@gmail.com

ENVFILE=$HOME/k8s_install/shell/00-env.sh

# env
if [ -f $ENVFILE ];then
  . $ENVFILE
else
  echo "$ENVFILE not found!"
  exit
fi
test ! -f /var/lib/etcd && mkdir -p /var/lib/etcd
test ! -f /etc/etcd && mkdir -p /etc/etcd

cp $etcd_pkg_dir/bin/etcd* /usr/local/bin
chmod +x /usr/local/bin/*
cat $etcd_pkg_dir/config/etcd.conf |sed 's#{NODE_NAME}#'"$NODE_NAME"'#g;s#{CURRENT_IP}#'"$CURRENT_IP"'#g;s#{ETCD_NODES}#'"$ETCD_NODES"'#g' > /etc/etcd/etcd.conf
cp $etcd_pkg_dir/config/etcd.service /usr/lib/systemd/system/etcd.service

# disable firewalld & start etcd
systemctl daemon-reload
systemctl disable firewalld
systemctl stop firewalld
systemctl enable etcd
systemctl restart etcd

# write kubernete pod ip range
### 向 etcd 写入集群 Pod 网段信息
etcdctl \
  --endpoints=${ETCD_ENDPOINTS} \
  --ca-file=/etc/kubernetes/ssl/ca.pem \
  --cert-file=/etc/kubernetes/ssl/kubernetes.pem \
  --key-file=/etc/kubernetes/ssl/kubernetes-key.pem \
  set ${FLANNEL_ETCD_PREFIX}/config '{"Network":"'${CLUSTER_CIDR}'","Backend":{"Type":"vxlan"}}'
