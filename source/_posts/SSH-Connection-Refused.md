---
title: SSH连接远程主机出现的Connection Refused问题
date: 2023-04-23 20:30:22
categories:
 - Bugs
tags:
 - Bugs
 - SSH
---

```shell
ssh root@144.202.12.32
ssh: connect to host 144.202.12.32 port 22: Connection refused
```

查的一些博客说修改mac设置成允许远程连接(这其实是允许别人连接你的mac电脑比如`ssh localhost`), 还有修改服务器里的配置文件`/etc/ssh/ssh_config`, 22端口取消注释, 都没用, 

直接去服务器卸载ssh再重装就好了

```shell
sudo yum remove openssh-server
sudo yum install openssh-server

# sudo systemctl stop sshd
sudo systemctl start sshd
# 查看状态
service sshd status
```

注意上面我们检查ssh服务是否打开输入的是 `service sshd status`, 并不是上面的`ssh status`, 在我的服务器上输入`ssh status`会显示`Unit ssh.service could not be found.`所以根据实际情况而定. 

然后我为域名设置了两个A记录(`@`和`www`)后, 使用域名连接主机出现了以下情况, 

```shell
$ ssh root@davidzhu.xy 
ssh: Could not resolve hostname davidzhu.xy: nodename nor servname provided, or not known

# 成功连接
$ ssh root@www.davidzhu.xyz
The authenticity of host 'www.davidzhu.xyz (144.202.12.32)' can't be established.
ED25519 key fingerprint is SHA256:NpOMboPt3497x7ISpCbqOf/oCu4FNMqtzcKQPELZvUw.
This host key is known by the following other names/addresses:
...
...
```

在论坛问了一下,  这个应该是DNS缓存问题, 即`davidzhu.xyz`被被解析到了旧的ip, 因为我刚修改, 

在另一台电脑上的测试:

Seems to be working as expected. Both resolve to the same IP

```
dig davidzhu.xyz +short
144.202.12.32

dig www.davidzhu.xyz +short
144.202.12.32
```

ssh works as well

```
~
❯ ssh root@davidzhu.xyz
The authenticity of host 'davidzhu.xyz (144.202.12.32)' can't be established.
ED25519 key fingerprint is SHA256:NpOMboPt3497x7ISpCbqOf/oCu4FNMqtzcKQPELZvUw.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'davidzhu.xyz' (ED25519) to the list of known hosts.
root@davidzhu.xyz's password:


~ took 10s
❯ ssh root@www.davidzhu.xyz
The authenticity of host 'www.davidzhu.xyz (144.202.12.32)' can't be established.
ED25519 key fingerprint is SHA256:NpOMboPt3497x7ISpCbqOf/oCu4FNMqtzcKQPELZvUw.
This host key is known by the following other names/addresses:
    ~/.ssh/known_hosts:64: davidzhu.xyz
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'www.davidzhu.xyz' (ED25519) to the list of known hosts.
root@www.davidzhu.xyz's password:
```
