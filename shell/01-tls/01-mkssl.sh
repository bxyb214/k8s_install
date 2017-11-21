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

current_timestamp=`date +%Y%m%d%H%M%S`

if test -d $ssl_work_dir;then
  mv $ssl_work_dir ../$ssl_dir.$current_timestamp
fi

mkdir -p $ssl_work_dir && cd $ssl_work_dir || (echo "$ssl_dir not exist";exit 1)
export PATH=$PATH:$ssl_bin_dir

# check bin file exist
for i in cfssl cfssljson cfssl-certinfo;do
  test ! -f $ssl_bin_dir/$i && echo "file $ssl_bin_dir/$i not found!" && exit 1
done

# check config file exist
for i in ca-config.json kubernetes-csr.json admin-csr.json kube-proxy-csr.json;do
  test ! -f $ssl_config_dir/$i && echo "file $ssl_config_dir/$i not found!" && exit 1
done

# create
## create ca
cfssl gencert -initca $ssl_config_dir/ca-csr.json | cfssljson -bare ca

## create kubernetes
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=$ssl_config_dir/ca-config.json -profile=kubernetes $ssl_config_dir/kubernetes-csr.json | cfssljson -bare kubernetes

## create admin
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=$ssl_config_dir/ca-config.json -profile=kubernetes $ssl_config_dir/admin-csr.json | cfssljson -bare admin

## create kube-proxy
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=$ssl_config_dir/ca-config.json -profile=kubernetes $ssl_config_dir/kube-proxy-csr.json | cfssljson -bare kube-proxy

# deploy ssl key files
echo -e "\e[32mDeploy SSL KEY FILE to /etc/kubernetes/ssl \e[0m"
if test ! -f /etc/kubernetes/ssl;then
   mkdir -p /etc/kubernetes/ssl && \cp $ssl_work_dir/*.pem /etc/kubernetes/ssl
fi

## create admin client key
cd /etc/kubernetes/ssl
openssl pkcs12 -export -in admin.pem -inkey admin-key.pem -out /etc/kubernetes/web-cret.p12
echo -e "\e[33mCreate web-cert key file to /etc/kubernetes \e[0m"
echo "                                    "
