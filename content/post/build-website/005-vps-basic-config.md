---
title: Basic Configuration of VPS
date: 2023-09-09 15:53:57
categories:
 - build website
tags:
 - build website
typora-root-url: ../../../static
---

## 1. Login without using keypairs

Copy your ssh public key on your computer into the `~/.ssh/authorized_keys` file on you EC2 instance. 

On you local machine:

```shell
$ cat ~/.ssh/id_rsa.pub 
...
```

Copy the content into your EC2 instance:

```shell
$ sudo vi .ssh/authorized_keys
```

Then you can login directly:

## 2. oh-my-zsh shell

```shell
sudo apt install zsh -y
chsh -s /bin/zsh
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
```

## 3. Set up ufw 

```shell
➜  ~ sudo ufw status
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
22/tcp (v6)                ALLOW       Anywhere (v6)

# if you need 443, do this:
➜  ~ sudo ufw allow 443
Rule added
Rule added (v6)
```

Learn more: [ufw vs AWS Security Group - David's Blog](https://davidzhu.xyz/post/build-website/006-ufw-aws-sg/)

## 4. Other info

After basic settings, on **Alpine Linux**: 1 vCPUs, 512 MB RAM, 10G SSD, Vultr VPS:

```
➜  ~ df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs         10M     0   10M   0% /dev
shm             231M     0  231M   0% /dev/shm
/dev/vda2       9.2G  579M  8.2G   7% /
tmpfs            93M  336K   92M   1% /run
/dev/vda1       256M  266K  256M   1% /boot/efi
tmpfs           231M     0  231M   0% /tmp

➜  ~ speedtest-cli
Testing download speed................................................................................
Download: 1648.48 Mbit/s
Testing upload speed......................................................................................................
Upload: 1013.83 Mbit/s

❯ iperf -c 149.22.12.30 -i 3 -t 18 -R
[ ID] Interval       Transfer     Bandwidth
[ *1] 0.00-3.00 sec  77.2 MBytes   216 Mbits/sec
[ *1] 3.00-6.00 sec   105 MBytes   295 Mbits/sec
[ *1] 6.00-9.00 sec   101 MBytes   282 Mbits/sec
[ *1] 9.00-12.00 sec  82.3 MBytes   230 Mbits/sec
[ *1] 12.00-15.00 sec  87.4 MBytes   244 Mbits/sec
[ *1] 15.00-18.00 sec   101 MBytes   282 Mbits/sec
[ *1] 0.00-18.65 sec   575 MBytes   259 Mbits/sec

❯ iperf -c 149.22.12.30 -i 3 -t 18
[ ID] Interval       Transfer     Bandwidth
[  1] 0.00-3.00 sec   102 MBytes   286 Mbits/sec
[  1] 3.00-6.00 sec   104 MBytes   290 Mbits/sec
[  1] 6.00-9.00 sec   100 MBytes   281 Mbits/sec
[  1] 9.00-12.00 sec  82.0 MBytes   229 Mbits/sec
[  1] 12.00-15.00 sec  83.0 MBytes   232 Mbits/sec
[  1] 15.00-18.00 sec  72.0 MBytes   201 Mbits/sec
[  1] 0.00-18.10 sec   544 MBytes   252 Mbits/sec

Interval: The time frame for the bandwidth measurement. For example, "0.00-3.00 sec" is the first 3 seconds of the test.
Transfer: The amount of data transferred during the interval. For example, "69.9 MBytes" were transferred in the first 3 seconds.
Bandwidth: The calculated network bandwidth during the interval. For example, in the first 3 seconds, the bandwidth was "195 Mbits/sec".
```

![aa](/005-vps-basic-config/aa.png)
