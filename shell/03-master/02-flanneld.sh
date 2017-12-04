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

# deploy
test ! -f $flanneld_rpm_file/flannel-0.7.1-1.el7.x86_64.rpm && echo "$flanneld_rpm_file not found!" && exit 1
yum install -y $flanneld_rpm_file/flannel-0.7.1-1.el7.x86_64.rpm
sed 's#{ETCD_ENDPOINTS}#'"$ETCD_ENDPOINTS"'#g;s#{FLANNEL_ETCD_PREFIX}#'"$FLANNEL_ETCD_PREFIX"'#g;s#{NET_INTERFACE_NAME}#'"$NET_INTERFACE_NAME"'#g' $flanneld_config/flanneld > /etc/sysconfig/flanneld

# reset 
systemctl daemon-reload
systemctl enable flanneld
systemctl restart flanneld
systemctl status -l flanneld
