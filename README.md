# 00 Kubernetes 1.8.4 版本环境（持续完善中）
## 系统版本及软件版本
+ CentOS Linux release 7.4.1708 (Core) 
+ 3.10.0-693.2.2.el7.x86_64
+ kubernetes 1.7.5
+ docker version 1.12.6, build 3a094bd/1.12.6
+ etcdctl version: 3.2.1 API version: 2
+ Flanneld 0.7.1 vxlan 网络
+ TLS 认证通信相关组件，(如etcd、kubernetes master 和 node)
+ RBAC 授权
+ kubelet TLS BootStrapping、kubedns、dashboard、heapster(influxdb、grafana)、EFK (elasticsearch、fluentd、kibana) 插件

## 安装目录结构
```
[root@node61 ~]# tree k8s_install/
k8s_install/
├── haproxy.cfg
├── pkg
│   ├── cfssl
│   │   ├── bin
│   │   │   ├── 1.2
│   │   │   ├── cfssl
│   │   │   ├── cfssl-certinfo
│   │   │   └── cfssljson
│   │   └── config
│   │       ├── admin-csr.json
│   │       ├── ca-config.json
│   │       ├── ca-csr.json
│   │       ├── kube-proxy-csr.json
│   │       └── kubernetes-csr.json
│   ├── etcd
│   │   ├── bin
│   │   │   ├── 3.2.1
│   │   │   ├── etcd
│   │   │   └── etcdctl
│   │   └── config
│   │       ├── etcd.conf
│   │       └── etcd.service
│   ├── flanneld
│   │   ├── bin
│   │   │   └── flannel-0.7.1-1.el7.x86_64.rpm
│   │   └── config
│   │       └── flanneld
│   └── kubernetes
│       ├── bin
│       │   ├── 1.7.5
│       │   └── kubernetes-server-linux-amd64.tar.gz
│       └── config
│           ├── apiserver
│           ├── config
│           ├── controller-manager
│           ├── kube-apiserver.service
│           ├── kube-controller-manager.service
│           ├── kubelet
│           ├── kubelet.service
│           ├── kube-proxy.service
│           ├── kube-scheduler.service
│           ├── proxy
│           └── scheduler
├── shell
│   ├── 00-env.sh
│   ├── 01-tls
│   │   └── 01-mkssl.sh
│   ├── 02-etcd
│   │   └── 01-etcd.sh
│   ├── 03-master
│   │   ├── 01-flanneld.sh
│   │   └── 02-kube-master.sh
│   ├── 04-node
│   │   ├── 01-flanneld.sh
│   │   └── 02-kube-node.sh
│   ├── 05-test
│   │   ├── 77-etcdctl.sh
│   │   ├── 88-etcd-status.sh
│   │   └── 99-apiserver-ha.sh
│   ├── kube-config.sh
│   └── test.txt
├── ssl_workdir
│   ├── admin.csr
│   ├── admin-key.pem
│   ├── admin.pem
│   ├── ca.csr
│   ├── ca-key.pem
│   ├── ca.pem
│   ├── kube-proxy.csr
│   ├── kube-proxy-key.pem
│   ├── kube-proxy.pem
│   ├── kubernetes.csr
│   ├── kubernetes-key.pem
│   └── kubernetes.pem
├── yaml
│   ├── 01-kubedns
│   │   ├── kubedns-cm.yaml
│   │   ├── kubedns-controller.yaml
│   │   ├── kubedns-sa.yaml
│   │   └── kubedns-svc.yaml
│   ├── 02-dashboard
│   │   ├── dashboard-controller.yaml
│   │   ├── dashboard-rbac.yaml
│   │   └── dashboard-service.yaml
│   ├── 03-heapster
│   │   ├── grafana-deployment.yaml
│   │   ├── grafana-service.yaml
│   │   ├── heapster-deployment.yaml
│   │   ├── heapster-rbac.yaml
│   │   ├── heapster-service.yaml
│   │   ├── influxdb-cm.yaml
│   │   ├── influxdb-deployment.yaml
│   │   └── influxdb-service.yaml
│   ├── 04-ingress
│   │   ├── default-backend.yml
│   │   ├── nginx-ingress-controller-rbac.yml
│   │   ├── nginx-ingress-controller-service.yml
│   │   └── nginx-ingress-controller.yml
│   ├── 05-domain
│   │   ├── dashboard-ingress.yaml
│   │   ├── efk-ingress.yaml
│   │   ├── grafana-ingress.yaml
│   │   └── prometheus-ingress.yaml
│   ├── 06-efk
│   │   ├── es-controller.yaml
│   │   ├── es-rbac.yaml
│   │   ├── es-service.yaml
│   │   ├── fluentd-es-ds.yaml
│   │   ├── fluentd-es-rbac.yaml
│   │   ├── kibana-controller.yaml
│   │   └── kibana-service.yaml
│   ├── 07-grafana
│   │   ├── grafana-deployment.yaml
│   │   ├── grafana-rbac.yaml
│   │   └── grafana-service.yaml
│   ├── 08-prometheus
│   │   ├── prometheus-alertmanager-configmap.yaml
│   │   ├── prometheus-alert-rules-configmap.yaml
│   │   ├── prometheus-deployment.yaml
│   │   ├── prometheus-etcd-ex-svc.yaml
│   │   ├── prometheus-kubernetes-configmap.yaml
│   │   ├── prometheus-node-exporter.yaml
│   │   ├── prometheus-rbac.yml
│   │   └── prometheus-service.yaml
│   └── 09.rabbitmq
│       ├── rabbitmq-autocluster-statefulset.yaml
│       ├── rabbitmq-cookie-secret.yaml
│       ├── rabbitmq-rbac.yaml
│       └── rabbitmq-svc.yaml
└── yaml.bak
    ├── 01-kubedns
    │   ├── kubedns-cm.yaml
    │   ├── kubedns-controller.yaml
    │   ├── kubedns-sa.yaml
    │   └── kubedns-svc.yaml
    ├── 02-dashboard
    │   ├── dashboard-controller.yaml
    │   ├── dashboard-rbac.yaml
    │   └── dashboard-service.yaml
    ├── 04-ingress
    │   ├── default-backend.yml
    │   ├── nginx-ingress-controller.aaaa
    │   ├── nginx-ingress-controller-rbac.yml
    │   ├── nginx-ingress-controller-service.yml
    │   └── nginx-ingress-controller.yml
    ├── 05-efk
    │   ├── es-controller.yaml
    │   ├── es-rbac.yaml
    │   ├── es-service.yaml
    │   ├── fluentd-es-ds.yaml
    │   ├── fluentd-es-rbac.yaml
    │   ├── kibana-controller.yaml
    │   └── kibana-service.yaml
    ├── 06-domain
    ├── nginx-ingress-controller.yml
    ├── other
    │   ├── 04-efk
    │   │   ├── es-controller.yaml
    │   │   ├── es-rbac.yaml
    │   │   ├── es-service.yaml
    │   │   ├── fluent-bit-acc.yml
    │   │   ├── fluent-bit-daemonset-elasticsearch.yaml
    │   │   ├── fluent-bit-rbac.yaml
    │   │   ├── kibana-controller.yaml
    │   │   └── kibana-service.yaml
    │   ├── 05-ingress
    │   │   ├── 1nginx-ingress-rbac.yml
    │   │   ├── 2default-backend.yml
    │   │   ├── 3nginx-ingress-controller.yml
    │   │   └── 4nginx-ingress-service.yml
    │   ├── 06-fluent-bit
    │   │   ├── fluent-bit-acc.yml
    │   │   ├── fluent-bit-daemonset-elasticsearch.yaml
    │   │   └── fluent-bit-rbac.yaml
    │   ├── 07-domain
    │   │   ├── domain-dashboard.yml
    │   │   ├── kibana-logging.yml
    │   │   └── monitoring-grafana.yml
    │   ├── dns
    │   │   ├── docker
    │   │   │   └── Dockerfile
    │   │   ├── kube-config
    │   │   │   ├── google
    │   │   │   │   └── heapster.yaml
    │   │   │   ├── influxdb
    │   │   │   │   ├── grafana.yaml
    │   │   │   │   ├── heapster.yaml
    │   │   │   │   └── influxdb.yaml
    │   │   │   ├── rbac
    │   │   │   │   └── heapster-rbac.yaml
    │   │   │   ├── standalone
    │   │   │   │   └── heapster-controller.yaml
    │   │   │   ├── standalone-test
    │   │   │   │   ├── heapster-controller.yaml
    │   │   │   │   ├── heapster-service.yaml
    │   │   │   │   └── heapster-summary-controller.yaml
    │   │   │   └── standalone-with-apiserver
    │   │   │       ├── common.sh
    │   │   │       ├── heapster-apiserver-secrets.template
    │   │   │       ├── heapster-deployment.yaml
    │   │   │       ├── heapster-service.yaml
    │   │   │       └── startup.sh
    │   │   └── kube.sh
    │   └── efk-rbac.yml
    └── yaml-old
        ├── 07-prometheus
        │   ├── prometheus-alertmanager-configmap.yaml
        │   ├── prometheus-alert-rules-configmap.yaml
        │   ├── prometheus-deployment.yaml
        │   ├── prometheus-etcd-ex-svc.yaml
        │   ├── prometheus-kubernetes-configmap.yaml
        │   ├── prometheus-node-exporter.yaml
        │   ├── prometheus-rbac.yml
        │   └── prometheus-service.yaml
        ├── 09-rabbitmq-autocluster_for_k8s1.7
        │   ├── rabbitmq-autocluster-statefulset.yaml
        │   ├── rabbitmq-cookie-secret.yaml
        │   └── rabbitmq-rbac.yaml
        └── nginx-shensuo
            ├── hpa-nginx.yaml
            ├── nginx-deployment.yaml
            └── nginx-svc.yaml

54 directories, 168 files

```

## 集群机器
+ 192.168.61.61
+ 192.168.61.62
+ 192.168.61.63
+ 192.168.61.64
+ 192.168.61.65
+ 192.168.61.66

## 安装脚本
```
[root@node61 ~/k8s_install/shell]# ls
00-env.sh  01-tls  02-etcd  03-master  04-node  05-test  kube-config.sh  test.txt
```

# 1. 创建 TLS 证书和秘钥(在一个管理节点运行，其他节点拷贝即可)
kubernetes 系统各组件需要使用 TLS 证书对通信进行加密，本文档使用 CloudFlare 的 PKI 工具集 cfssl 来生成 Certificate Authority (CA) 和其它证书。

生成的 CA 证书和秘钥文件如下：
+ ca-key.pem
+ ca.pem
+ kubernetes-key.pem
+ kubernetes.pem
+ kube-proxy.pem
+ kube-proxy-key.pem
+ admin.pem
+ admin-key.pem

使用证书的组件如下：
+ etcd：使用 ca.pem、kubernetes-key.pem、kubernetes.pem；
+ kube-apiserver：使用 ca.pem、kubernetes-key.pem、kubernetes.pem；
+ kubelet：使用 ca.pem；
+ kube-proxy：使用 ca.pem、kube-proxy-key.pem、kube-proxy.pem；
+ kubectl：使用 ca.pem、admin-key.pem、admin.pem；
+ kube-controller、kube-scheduler与kube-apiserver部署在同一台机器上且使用非安全端口通信，故不需要证书。

> kubernetes 1.4 开始支持 TLS Bootstrapping 功能，由 kube-apiserver 为客户端生成 TLS 证书，这样就不需要为每个客户端生成证书（该功能目前仅支持 kubelet，所以本文档没有为 kubelet 生成证书和秘钥）。

## 添加集群机器ip
``` bash
# cat /root/k8s_install/pkg/cfssl/config/kubernetes-csr.json
{
  "CN": "kubernetes",
  "hosts": [
    "127.0.0.1",
    "10.254.0.1",
    "192.168.61.61",
    "192.168.61.62",
    "192.168.61.63",
    "192.168.61.52",
    "192.168.61.53",
    "192.168.61.54",
    "192.168.61.100",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc.cluster.local"
  ],
  ...
}

```
## 使用脚本生成TLS 证书和秘钥
```
# cd ~/k8s_install/shell/01-tls
# ./01-mkssl.sh
```
> 检查/etc/kubernetes/ssl目录下自动生成相关的证书完整性

## 分发证书
将生成的证书和秘钥文件（后缀名为.pem）拷贝到所有机器的 /etc/kubernetes/ssl 目录下

> 当前机器已在/etc/kubernetes/ssl生成了证书，只需要将该目录copy至其他节点机器上

> 确保 /etc/kubernetes/token.csv 也一并分发

# 02 部署高可用etcd集群
kuberntes 使用 etcd 存储数据，本文档部署3个节点的 etcd 高可用集群，(复用kubernetes master机器)，分别命名为node61、node62、node63：

+ node61：192.168.61.61
+ node62：192.168.61.62
+ node63：192.168.61.63

## 修改使用的变量
修改当前机器上的00-globalenv.sh上的相关ip与配置信息
+  CURRENT_IP
+  basedir
+  FLANNEL_ETCD_PREFIX
+  NODE_NAME
+  NODE_IPS
+  ETCD_NODES
+  ETCD_ENDPOINTS

## 确认TLS 认证文件
为 etcd 集群创建加密通信的 TLS 证书，复用/etc/kubernetes/ssl证书,具体如下：
+ ca.pem 
+ kubernetes-key.pem 
+ kubernetes.pem
> kubernetes 证书的hosts字段列表中包含上面三台机器的 IP，否则后续证书校验会失败；

## 安装etcd
执行安装脚本/root/k8s_install/shell/02-etcd/01-etcd.sh 
``` bash
# /root/k8s_install/shell/02-etcd/01-etcd.sh
```
> 在所有的etcd节点重复上面的步骤，直到所有机器etcd 服务都已启动。

## 确认集群状态
三台 etcd 的输出均为 healthy 时表示集群服务正常（忽略 warning 信息）
``` bash
# /root/k8s_install/shell/05-test77-etcd-status.sh
```
## 检查 etcd集群中配置的网段信息
```
[root@node61 shell]# ./77-etcdctl.sh get /kubernetes/network/config
```

# 03 部署kubernetes master节点
kubernetes master 节点包含的组件：
+ kube-apiserver
+ kube-scheduler
+ kube-controller-manager
+ flanneld

> 安装flanneld组件用以dashboard，heapster访问node上的pod用

目前这三个组件需要部署在同一台机器上

## 修改环境变量
确认以下环境变量为当前机器上正确的参数
+  CURRENT_IP
+  basedir
+  FLANNEL_ETCD_PREFIX
+  ETCD_ENDPOINTS
+  KUBE_APISERVER
+  kube_pkg_dir
+  kube_tar_file

> ETCD_ENDPOINTS该参数被flanneld启动使用

## 确认TLS 证书文件
确认token.csv，ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem 存在
``` bash
# find /etc/kubernetes/
/etc/kubernetes/
/etc/kubernetes/ssl
/etc/kubernetes/ssl/admin-key.pem
/etc/kubernetes/ssl/admin.pem
/etc/kubernetes/ssl/ca-key.pem
/etc/kubernetes/ssl/ca.pem
/etc/kubernetes/ssl/kube-proxy-key.pem
/etc/kubernetes/ssl/kube-proxy.pem
/etc/kubernetes/ssl/kubernetes-key.pem
/etc/kubernetes/ssl/kubernetes.pem
/etc/kubernetes/token.csv
```
## 安装和配置 flanneld
### 检查修改flanneld指定的网卡信息
+ 查看实际ip所在的网卡名字
``` bash
[root@k8s-master shell]# ip a
```
+ 设置网卡名字为：**ens160**
``` bash
# vim /root/k8s_install/shell/00-setenv.sh
NET_INTERFACE_NAME=ens160
```
> 因flanneld启动会绑定网卡以生成虚拟ip信息，若不指定，会自动找寻除lookback外的网卡信息

### 安装并启动flanneld
```
# /root/k8s_install/shell/03-master/01-flanneld.sh
```
> 该脚本会安装flanneld软件，以供dashboard，heapster可以通过web访问

## 部署kube-apiserver,kube-scheduler,kube-controller-manager
执行部署脚本，部署相关master应用
``` bash
# /root/k8s_install/shell/03-master/02-kube-master.sh
```
> 该脚本中会安装kube master相关组件并配置kubectl config

## 验证 master 节点功能
``` bash
[root@node76 ~]# kubectl get componentstatuses
NAME                 STATUS    MESSAGE              ERROR
controller-manager   Healthy   ok                   
scheduler            Healthy   ok                   
etcd-0               Healthy   {"health": "true"}   
etcd-1               Healthy   {"health": "true"}   
etcd-2               Healthy   {"health": "true"} 
```

# 04 部署kubernetes node节点
kubernetes Node 节点包含如下组件：
+ flanneld
+ docker
+ kubelet
+ kube-proxy

## 确认TLS 证书文件
确认token.csv，ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem 存在
```
# find /etc/kubernetes/
/etc/kubernetes/
/etc/kubernetes/ssl
/etc/kubernetes/ssl/admin-key.pem
/etc/kubernetes/ssl/admin.pem
/etc/kubernetes/ssl/ca-key.pem
/etc/kubernetes/ssl/ca.pem
/etc/kubernetes/ssl/kube-proxy-key.pem
/etc/kubernetes/ssl/kube-proxy.pem
/etc/kubernetes/ssl/kubernetes-key.pem
/etc/kubernetes/ssl/kubernetes.pem
/etc/kubernetes/token.csv
```
## 安装和配置 flanneld  
具体见master上安装flanneld步骤

## 安装和配置 docker
```
# yum install docker -y

```
> 若安装失败，请检查os版本安装时，是否是最小化安装，或者根据报错依赖信息，直接删除掉systemd-python-219-19.el7.x86_64和libcgroup-tools-0.41-8.el7.x86_64

```
# yum remove -y systemd-python-219-19.el7.x86_64 libcgroup-tools-0.41-8.el7.x86_64
```
> 该脚本会自动关闭并配置selinux为被动模式并停止防火墙;
> + 设置selinux为被动模式，是避免docker创建文件系统报权限失败；
> + 设置firewalld是为了防止添加的iptables信息与docker自身的冲突，造成访问失败；

```
# 可以通过如下命令查看下相关信息
# sestatus
# systemctl status -l firewalld
```

## 安装和配置 kubelet和kube-proxy
```
# /root/k8s_install/shell/04-node/01-flanneld.sh
# /root/k8s_install/shell/04-node/02-kube-node.sh
```

# 05 部署kubedns 插件
## 安装
``` bash
[root@node61 ~/k8s_install/yaml/01-kubedns]# ll -ltr
total 20
-rw-r--r--. 1 root root 1061 Aug 17 16:03 kubedns-svc.yaml
-rw-r--r--. 1 root root  195 Aug 17 16:03 kubedns-sa.yaml
-rw-r--r--. 1 root root  752 Aug 17 16:03 kubedns-cm.yaml
-rw-r--r--. 1 root root 5535 Oct 11 15:25 kubedns-controller.yaml

[root@node61 ~/k8s_install/yaml/01-kubedns]# kubectl create -f 01-kubedns/
configmap "kube-dns" created
deployment "kube-dns" created
serviceaccount "kube-dns" created
service "kube-dns" created
```
> 确保yaml配置的image源地址正确

## 确认状态
``` bash
[root@node61 ~/k8s_install/yaml/01-kubedns]# kubectl get svc,po -o wide --all-namespaces
NAMESPACE     NAME                        CLUSTER-IP       EXTERNAL-IP   PORT(S)                         AGE       SELECTOR
default       svc/kubernetes              10.254.0.1       <none>        443/TCP                         21h       <none>
kube-system   svc/default-http-backend    10.254.232.193   <none>        80/TCP                          16h       k8s-app=default-http-backend
```

# 06 部署 dashboard 插件
## 创建
``` bash
[root@node71 ~/install/yml]# ls -ltr  ~/install/yml/02-dashboard/
total 12
-rw-r--r-- 1 root root  355 Jul  5 12:43 dashboard-service.yaml
-rw-r--r-- 1 root root  384 Jul  5 12:43 dashboard-rbac.yaml
-rw-r--r-- 1 root root 1193 Jul  7 11:04 dashboard-controller.yaml

[root@node71 ~/install/yml]# kubectl create -f 02-dashboard
deployment "kubernetes-dashboard" created
serviceaccount "dashboard" created
clusterrolebinding "dashboard" created
service "kubernetes-dashboard" created
```
## 确认状态
``` bash
[root@node71 ~/install/yml]# kubectl get svc,po -o wide --all-namespaces
NAMESPACE     NAME                       CLUSTER-IP     EXTERNAL-IP   PORT(S)         AGE       SELECTOR
default       svc/kubernetes             10.254.0.1     <none>        443/TCP         3d        <none>
kube-system   svc/kube-dns               10.254.0.2     <none>        53/UDP,53/TCP   12m       k8s-app=kube-dns
kube-system   svc/kubernetes-dashboard   10.254.41.68   <nodes>       80:8522/TCP     19s       k8s-app=kubernetes-dashboard

NAMESPACE     NAME                                       READY     STATUS    RESTARTS   AGE       IP            NODE
kube-system   po/kube-dns-682617846-2k9xn                3/3       Running   0          12m       172.30.61.2   192.168.61.73
kube-system   po/kubernetes-dashboard-2172513996-thb5q   1/1       Running   0          18s       172.30.57.2   192.168.61.72
```
查看分配的 NodePort
+ 通过之前的命令，可以看到svc/kubernetes-dashboard NodePort 8522映射到 dashboard pod 80端口；

## 访问dashboard
+ kubernetes-dashboard 服务暴露了 NodePort，可以使用 http://NodeIP:nodePort 地址访问 dashboard；
``` bash
[root@node61 ~/k8s_install/yaml/01-kubedns]# kubectl get po,svc -o wide --all-namespaces |grep dashboard
kube-system   po/kubernetes-dashboard-1054243260-wt0qb       1/1       Running   0          21h       172.18.13.5   192.168.61.64

kube-system   svc/kubernetes-dashboard    10.254.130.193   <nodes>       80:24850/TCP                    21h       k8s-app=kubernetes-dashboard               4d        k8s-app=kubernetes-dashboard
```
> 直接访问： http://192.168.61.75:24850 或者 http://192.168.61.61:8080/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/#!/workload?namespace=default
+ 通过 kube-apiserver 访问 dashboard；

``` bash
任意安装kubectl节点执行
# kubectl proxy --address=0.0.0.0 --accept-hosts='^*$'
# 通过 http://ip:8001/ui/ 访问 kubernetes-dashboard
```

# 07 部署 Heapster插件
## 创建
``` bash
[root@node61 ~/install/yml]# kubectl create -f 03-heapster
deployment "monitoring-grafana" created
service "monitoring-grafana" created
deployment "heapster" created
serviceaccount "heapster" created
clusterrolebinding "heapster" created
service "heapster" created
configmap "influxdb-config" created
deployment "monitoring-influxdb" created
service "monitoring-influxdb" created
```
## 确认状态
``` bash
[root@node61 ~/install/yml]# kubectl get svc,po -o wide --all-namespaces
kube-system   svc/heapster               10.254.244.190   <none>        80/TCP                        28s       k8s-app=heapster
kube-system   svc/monitoring-grafana     10.254.72.242    <none>        80/TCP                        28s       k8s-app=grafana
kube-system   svc/monitoring-influxdb    10.254.129.64    <nodes>       8086:8815/TCP,8083:8471/TCP   27s       k8s-app=influxdb

NAMESPACE     NAME                                       READY     STATUS    RESTARTS   AGE       IP            NODE
kube-system   po/heapster-1982147024-17ltr               1/1       Running   0          27s       172.30.61.4   192.168.61.73
kube-system   po/monitoring-grafana-1505740515-46r2h     1/1       Running   0          28s       172.30.57.3   192.168.61.72
kube-system   po/monitoring-influxdb-14932621-ztgh4      1/1       Running   0          27s       172.30.61.3   192.168.61.73
```
# 08 部署 EFK 插件
## 安装
``` bash
[root@node61 ~/install/yml/05-efk]# kubectl create -f ./      
replicationcontroller "elasticsearch-logging-v1" created
serviceaccount "elasticsearch" created
clusterrolebinding "elasticsearch" created
service "elasticsearch-logging" created
daemonset "fluentd-es-v1.23" created
serviceaccount "fluentd" created
clusterrolebinding "fluentd" created
deployment "kibana-logging" created
service "kibana-logging" created
```
> 确保yaml里面配置的image可用
## 给 Node 设置标签
DaemonSet fluentd-es-v1.23 只会调度到设置了标签 beta.kubernetes.io/fluentd-ds-ready=true 的 Node，需要在期望运行 fluentd 的 Node 上设置该标签；

``` bash
kubectl label nodes 192.168.61.64 beta.kubernetes.io/fluentd-ds-ready=true
```
## 检查状态

``` bash
[root@node61 ~]# kubectl cluster-info
Kubernetes master is running at https://192.168.61.61:6443
Elasticsearch is running at https://192.168.61.61:6443/api/v1/namespaces/kube-system/services/elasticsearch-logging/proxy
Heapster is running at https://192.168.61.61:6443/api/v1/namespaces/kube-system/services/heapster/proxy
Kibana is running at https://192.168.61.61:6443/api/v1/namespaces/kube-system/services/kibana-logging/proxy
KubeDNS is running at https://192.168.61.61:6443/api/v1/namespaces/kube-system/services/kube-dns/proxy
kubernetes-dashboard is running at https://192.168.61.61:6443/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy
monitoring-grafana is running at https://192.168.61.61:6443/api/v1/namespaces/kube-system/services/monitoring-grafana/proxy
monitoring-influxdb is running at https://192.168.61.61:6443/api/v1/namespaces/kube-system/services/monitoring-influxdb/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

## 访问
直接通过https访问会报错，可以通过http直接访问8080端口

> 在 Settings -> Indices 页面创建一个 index（相当于 mysql 中的一个database），选中 Index contains time-based events，使用默认的 logstash-* pattern，点击 Create ;

> 节点上的docker日志类型默认为journald, 若需要EFK监控，需要修改docker配置文件，并重启才可以操作生效

```
# vi /etc/sysconfig/docker
将如下配置
OPTIONS='--selinux-enabled --log-driver=journald --signature-verification=false'
OPTIONS='--signature-verification=false --storage-driver=overlay2'
修改为：
OPTIONS='--selinux-enabled --log-driver=json-file --signature-verification=false'
重启docker服务后，生效
```
