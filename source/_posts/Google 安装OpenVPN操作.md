---

title: 一文搞定 GCP OpenVPN 企业级部署
date: 2025-06-11 10:00:00
tags:
  - GCP
  - VPN
  - OpenVPN
  - 网络安全
categories:
  - 云计算
  - 网络架构
description: "从零搭建一套运行在 GCP 上的 OpenVPN 企业级环境，全流程详解：网络设置、实例部署、安全配置、双因子认证、成本优化，全都有！"
toc: true
comments: true

---

作为程序员，“远程访问”早已是日常生活的一部分——哪怕下班了，也可能突然被叫起来连 VPN 查日志。今天我就来分享如何在 GCP 上从零部署一套功能完备、安全可靠的 OpenVPN 环境。不绕弯子，干货满满，走你！

---

## 📌 一、前期准备工作

### 1. 登录 GCP 控制台

进入 [GCP 控制台](https://console.cloud.google.com/)，选好你所属的项目，这是你所有资源的“家”。

### 2. 创建 VPC 网络

这是后面 VPN 通信的基础网络：

- **名称**：如 `vpn-network`
- **子网**：比如 `10.10.0.0/16`，你可以根据实际业务划分。
- **私有 Google Access**：记得开启，后续如果你想让 VPN 用户访问 Cloud SQL，这就必须启用。

---

## 📌 二、Compute Engine 实例搭建

### 1. 创建实例

进入 Compute Engine 页面，点击“创建实例”，以下是推荐配置：

- **名称**：`openvpn-server`
- **区域**：建议选 `us-central1-a` 或离业务近的区域
- **机器类型**：`e2-standard-4`，性能与性价比兼得
- **系统镜像**：Ubuntu 22.04 LTS，50GB SSD
- **防火墙选项**：可不勾选 HTTP/HTTPS（视需求而定）

### 2. 分配静态 IP

避免每次重启 IP 变动：

- 打开“VPC 网络” → “外部 IP”
- 给你的实例绑定一个“静态 IP”，记住它，配置客户端时会用到。

---

## 📌 三、OpenVPN 服务安装和配置

### 1. SSH 登录实例

```bash
ssh username@<实例外部IP地址>
```

### 2. 安装 OpenVPN 和 Easy-RSA

```bash
sudo apt update
sudo apt install openvpn easy-rsa
```

### 3. 搭建 CA 环境

```bash
mkdir ~/openvpn-ca
cd ~/openvpn-ca
vim vars
```

编辑 `vars` 文件：

```bash
export KEY_COUNTRY=”CN“
export KEY_PROVINCE=”Beijing“
export KEY_CITY=”Beijing“
export KEY_ORG=”MyCompany“
export KEY_EMAIL=”admin@example.com“
export KEY_OU=”IT“
export KEY_NAME=”server“
```

然后执行初始化：

```bash
source vars
./clean-all
./build-ca
```

### 4. 生成服务器证书和密钥

```bash
./build-key-server server
./build-dh
openvpn —genkey —secret keys/ta.key
```

拷贝相关文件：

```bash
sudo cp ca.crt server.crt server.key ta.key dh2048.pem /etc/openvpn
```

---

## 📌 四、OpenVPN 服务器配置

### 1. 配置 `server.conf`

```bash
sudo vim /etc/openvpn/server.conf
```

推荐配置如下：

```
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
tls-auth ta.key 0
server 10.8.0.0 255.255.0.0
ifconfig-pool-persist ipp.txt
push ”route 10.10.0.0 255.255.0.0“
client-to-client
keepalive 10 120
cipher AES-256-CBC
auth SHA256
persist-key
persist-tun
status /var/log/openvpn-status.log
log-append /var/log/openvpn.log
verb 3
```

### 2. 启动服务

```bash
sudo systemctl start openvpn@server
sudo systemctl enable openvpn@server
sudo systemctl status openvpn@server
```

---

## 📌 五、防火墙规则设置

进入 VPC 网络 → 防火墙规则：

- **名称**：`allow-openvpn`
- **协议/端口**：UDP 1194
- **来源 IP**：`0.0.0.0/0`（生产建议限制为可信网段）

---

## 📌 六、客户端证书与配置文件管理

### 1. 创建客户端证书

```bash
cd ~/openvpn-ca
source vars
./build-key client1
```

### 2. 创建 `.ovpn` 配置文件

```bash
vim client1.ovpn
```

示例如下：

```
client
dev tun
proto udp
remote <服务器外部IP> 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
auth SHA256
key-direction 1

<ca>
# 粘贴 ca.crt 内容
</ca>
<cert>
# 粘贴 client1.crt 内容
</cert>
<key>
# 粘贴 client1.key 内容
</key>
<tls-auth>
# 粘贴 ta.key 内容
</tls-auth>
```

---

## 📌 七、实现双因素认证（推荐 Google Authenticator）

### 1. 安装组件

```bash
sudo apt install libpam-google-authenticator
google-authenticator
```

扫码绑定后将生成动态验证码。

### 2. 修改配置支持 PAM

修改 OpenVPN 配置文件：

```bash
plugin /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so openvpn
```

修改 PAM 配置：

```bash
sudo vim /etc/pam.d/openvpn
```

添加：

```bash
auth required pam_google_authenticator.so nullok
```

重启服务：

```bash
sudo systemctl restart openvpn@server
```

---

## 📌 八、运维与监控

- **日志位置**：
  - `/var/log/openvpn.log`：连接详情
  - `/var/log/openvpn-status.log`：活跃连接信息
- **推荐工具**：GCP Operations Suite（原 Stackdriver）监控服务运行状态与告警

[此处建议插入 GCP 监控面板截图]

---

## 📌 九、成本控制建议

- **资源监控**：GCP 控制台内置图表 + 自定义报警
- **长期开销优化**：考虑使用 **预留实例（CUD）**，节省约 30% 成本

---

## 🏁 总结

从 VPC 到证书，从服务部署到双因子安全验证，再到成本监控，这一整套 OpenVPN 部署方案，足以支撑中小企业的日常远程办公需求。搭得好，不仅老板放心，自己也能安心远程撸代码了！

[参考：OpenVPN 官方文档](https://openvpn.net/community-resources/)

```