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
if test ! -f $kube_tar_file;then
echo "$kube_tar_file not found!"
else
test ! -d $kube_pkg_dir/bin/kubernetes && cd $kube_pkg_dir/bin && tar -xvf $kube_tar_file
cp $kube_bin_file/{kube-apiserver,kube-controller-manager,kube-scheduler,kubectl} /usr/local/bin
rm -rf $kube_bin_file/kubernetes
fi

# create service file and config file
test ! -f $kube_pkg_dir/config/config && echo "$kube_pkg_dir/config/config not found" && exit 1
sed 's#{KUBE_APISERVER}#http://'"$CURRENT_IP"':8080#g' $kube_pkg_dir/config/config > /etc/kubernetes/config
for i in apiserver scheduler controller-manager;do
  test ! -f $kube_pkg_dir/config/kube-$i.service && echo "kube-$i.server not found" && exit 1 

  # create services & replace var
  sed 's#{CURRENT_IP}#'"$CURRENT_IP"'#g;s#{SERVICE_CIDR}#'"$SERVICE_CIDR"'#g;s#{NODE_PORT_RANGE}#'"$NODE_PORT_RANGE"'#g;s#{CLUSTER_CIDR}#'"$CLUSTER_CIDR"'#g;s#{ETCD_ENDPOINTS}#'"$ETCD_ENDPOINTS"'#g' $kube_pkg_dir/config/kube-$i.service > /usr/lib/systemd/system/kube-$i.service

  # create config files
  sed 's#{CURRENT_IP}#'"$CURRENT_IP"'#g;s#{SERVICE_CIDR}#'"$SERVICE_CIDR"'#g;s#{NODE_PORT_RANGE}#'"$NODE_PORT_RANGE"'#g;s#{CLUSTER_CIDR}#'"$CLUSTER_CIDR"'#g;s#{ETCD_ENDPOINTS}#'"$ETCD_ENDPOINTS"'#g' $kube_pkg_dir/config/$i > /etc/kubernetes/$i

  # systemctl start
  systemctl daemon-reload
  systemctl enable kube-$i
  systemctl start kube-$i
  systemctl status -l kube-$i

done

# create config file
bash $HOME/k8s_install/shell/kube-config.sh kubectl
