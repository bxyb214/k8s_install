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

TYPE=$1
if [ $# -ne 1 ];then
  echo "usage: $0 { kubectl | kubelet | kube-proxy }"
  exit 1
fi


# get token
New_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
if test -f /etc/kubernetes/token.csv;then
  echo "/etc/kubernetes/token.csv found !" 
  BOOTSTRAP_TOKEN=$(awk -F',' '{print $1}' /etc/kubernetes/token.csv)
else
  echo "Create /etc/kubernetes/token.csv"
  mkdir -p /etc/kubernetes/
cat > /etc/kubernetes/token.csv <<EOF
${New_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF
  BOOTSTRAP_TOKEN=$(awk -F',' '{print $1}' /etc/kubernetes/token.csv)
fi

# config kubernetes 集群
if [ $TYPE == "kubectl" ];then
  kubectl config set-cluster kubernetes \
    --certificate-authority=/etc/kubernetes/ssl/ca.pem \
    --embed-certs=true \
    --server=${KUBE_APISERVER}
  # 设置客户端认证参数
  kubectl config set-credentials admin \
    --client-certificate=/etc/kubernetes/ssl/admin.pem \
    --embed-certs=true \
    --client-key=/etc/kubernetes/ssl/admin-key.pem
  # 设置上下文参数
  kubectl config set-context kubernetes \
    --cluster=kubernetes \
    --user=admin
  # 设置默认上下文
  kubectl config use-context kubernetes

elif [ $TYPE == "kubelet" ];then
  # 设置集群参数
  kubectl config set-cluster kubernetes \
    --certificate-authority=/etc/kubernetes/ssl/ca.pem \
    --embed-certs=true --server=${KUBE_APISERVER} --kubeconfig=bootstrap.kubeconfig
  # 设置客户端认证参数
  kubectl config set-credentials kubelet-bootstrap \
    --token=${BOOTSTRAP_TOKEN} --kubeconfig=bootstrap.kubeconfig
  # 设置上下文参数
  kubectl config set-context default \
    --cluster=kubernetes --user=kubelet-bootstrap --kubeconfig=bootstrap.kubeconfig
  # 设置默认上下文
  kubectl config use-context default --kubeconfig=bootstrap.kubeconfig
  # 
  mv bootstrap.kubeconfig /etc/kubernetes

elif [ $TYPE == "kube-proxy" ];then
  # 设置集群参数
  kubectl config set-cluster kubernetes \
    --certificate-authority=/etc/kubernetes/ssl/ca.pem \
    --embed-certs=true --server=${KUBE_APISERVER} --kubeconfig=kube-proxy.kubeconfig
  # 设置客户端认证参数
  kubectl config set-credentials kube-proxy \
    --client-certificate=/etc/kubernetes/ssl/kube-proxy.pem \
    --client-key=/etc/kubernetes/ssl/kube-proxy-key.pem \
    --embed-certs=true --kubeconfig=kube-proxy.kubeconfig
  # 设置上下文参数
  kubectl config set-context default \
    --cluster=kubernetes --user=kube-proxy --kubeconfig=kube-proxy.kubeconfig
  # 设置默认上下文
  kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

  #
  mv kube-proxy.kubeconfig /etc/kubernetes
else
  echo "input TYPE ERROR!"
  exit 1
fi

