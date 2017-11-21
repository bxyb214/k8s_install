### kubernetes Master api-server-HA

## 一、安装 Corosync以及pacemaker 部署
# 1.安装软件包
yum install -y pacemaker pcs psmisc policycoreutils-python corosync fence-agents-all
systemctl start pcsd.service
systemctl enable pcsd.service

# 2. 修改密码（全执行）
echo 'HAcluster123' | passwd --stdin hacluster

# 3. 验证集群
pcs cluster auth node71.ityunv.com node72.ityunv.com node73.ityunv.com -u hacluster -p HAcluster123 --force

# 4. 创建集群
pcs cluster setup --name k8s_cluster01 node71.ityunv.com node72.ityunv.com node73.ityunv.com

# 5. 启动集群
pcs cluster start --all

# 6. 检查配置是否正确
crm_verify -L -V                            #一般情况会跳出个错误；
pcs property set stonith-enabled=false      #禁用stonith；
pcs property set no-quorum-policy=ignore    #无法仲裁时，选择忽略；

# 7. 相关常用参数总结
pcs cluster enable --all                    #设置集群开机自动；
corosync-cfgtool -s                         #检查各节点通信状态(显示为no faults即为OK)；
pcs status corosync                         #查看coyosync状态；
pcs status

# 推荐使用crm，需要手动安装；
cd /etc/yum.repos.d/   
wget http://download.opensuse.org/repositories/network:/ha-clustering:/Stable/CentOS_CentOS-7/clustering.repo
yum makecache && yum -y install crmsh

## 二、配置haproxy实现与corosync和pacemaker结合
# 2.1 安装并配置haproxy
yum install -y haproxy
mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak01
echo -e "net.ipv4.ip_nonlocal_bind = 1" >> /etc/sysctl.conf
sysctl -p

# 2.2 修改配置文件，如下：
cat > /etc/haproxy/haproxy.cfg << EOF
global
  log 127.0.0.1 local0
  log 127.0.0.1 local1 notice
  maxconn 4096
  chroot /usr/share/haproxy
  user haproxy
  group haproxy
  daemon

defaults
     log global
     mode tcp
     timeout connect 5000ms
     timeout client 50000ms
     timeout server 50000ms

frontend stats-front
  bind *:8088
  mode http
  default_backend stats-back

backend stats-back
  mode http
  balance source
  stats uri /stats
  stats auth admin:king111

listen Kubernetes-Cluster
  bind 192.168.61.100:6443
  balance leastconn
  mode tcp
  server k8s_71 192.168.61.71:6443 check inter 2000 fall 3
  server k8s_72 192.168.61.72:6443 check inter 2000 fall 3
  server k8s_73 192.168.61.73:6443 check inter 2000 fall 3
EOF

# 启动服务
systemctl restart haproxy
systemctl status haproxy

# 2.3 配置VIP 并 将Haproxy加入到PCS集群
# 需要Haproxy节点把开机启动项关闭， crm 进入 PCS 命令行模式：
systemctl disable haproxy

#第一种方式通过CRM进行配置：
crm config
primitive crm-vip ocf:heartbeat:IPaddr2 params ip=192.168.61.100 cidr_netmask=24 nic=eno16777984 op start interval=0s timeout=20s op stop interval=0s timeout=20s  op monitor interval=20s timeout=30s  meta priority=100

primitive haproxy systemd:haproxy op start interval=0s timeout=20s op stop interval=0s timeout=20s op monitor interval=20s timeout=30s meta priority=100 target-role=Started
colocation haproxy-with-vip inf: crm-vip:Started haproxy:Started
verify
commit
exit

# 查看状态：
crm status

# 第二种方式通过pcs进行配置：
pcs resource create pcs-vip ocf:heartbeat:IPaddr2 ip=192.168.61.100 cidr_netmask=24 nic=eno16777984 op monitor interval=15s
pcs resource create apiserver systemd:kube-apiserver op monitor interval="5s"
pcs resource create haproxy systemd:haproxy op monitor interval="5s"
pcs constraint colocation add pcs-vip haproxy INFINITY  
pcs constraint order pcs-vip then haproxy

# 查看状态：
pcs status

# 删除资源
pcs resource delete haproxy
pcs resource delete pcs-vip
pcs resource delete crm-vip

#2.4 验证集群高可用
#可以自行试验，重启任意主机，看是否VIP切换到其他节点：
ip a

# 2.5 资源迁移
pcs resource  move apiserver node71.ityunv.com

# 2.6 设备备用节点
pcs cluster standby node72.ityunv.com