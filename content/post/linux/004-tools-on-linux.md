---
title: Tools Commonly Used on Linux
date: 2024-04-13 12:40:56
categories:
 - linux
tags:
 - linux
---

## 1. Test real time network IO and disk IO

```shell
dstat -d # check the disk speed at real time
dsat -n # check the network speed at real time
```

## 2. Check the network speed

`speedtest-cli` and `iperf3`: speedtest-cli measures speeds to public servers, reflecting general internet performance to the user; iperf3 can perform tests between any two points, ideal for in-depth performance testing in private or internal networks.

```shell
iperf3 -s -p 5202 # server

iperf3 -c server_ip_address -p 5202 # test the upload speed (client upload to server)
iperf3 -c server_ip_address -p 5202 -R # test the download speed (client download from server)
```


### Why the result of `iperf3` is different from `speedtest-cli`?

```shell
# run iperf3 on the client to test speed between client and server:
❯ iperf3 -c 104.152.xxx.122
Connecting to host 104.152.xxx.122, port 5201
[  5] local 192.168.2.15 port 64062 connected to 104.152.xxx.122 port 5201
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.00   sec  8.38 MBytes  70.1 Mbits/sec
[  5]   1.00-2.00   sec  15.0 MBytes   126 Mbits/sec
[  5]   2.00-3.00   sec  9.12 MBytes  76.6 Mbits/sec

❯ iperf3 -c 104.152.xxx.122 -R
Connecting to host 104.152.xxx.122, port 5201
Reverse mode, remote host 104.152.xxx.122 is sending
[  5] local 192.168.2.15 port 64067 connected to 104.152.xxx.122 port 5201
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.00   sec   128 KBytes  1.04 Mbits/sec
[  5]   1.00-2.00   sec   256 KBytes  2.10 Mbits/sec
[  5]   2.00-3.00   sec   256 KBytes  2.10 Mbits/sec
[  5]   3.00-4.00   sec   384 KBytes  3.14 Mbits/sec


# run speedtest-cli on the server:
➜  ~ speedtest-cli
Retrieving speedtest.net configuration...
Testing from WebNX (104.152.50.122)...
Retrieving speedtest.net server list...
Selecting best server based on ping...
Hosted by S&A Telephone (Allen, KS) [175.61 km]: 49.106 ms
Testing download speed................................................................................
Download: 425.75 Mbit/s
Testing upload speed......................................................................................................
Upload: 138.52 Mbit/s
```

1. **Test Server Differences**:
   - **Speedtest-cli** connects to servers likely hosted within your ISP's network or well-connected data centers.
   - **Iperf3** results depend on endpoints you specify, which might not have optimal network paths or server capabilities.

2. **Use of Parallel Connections**:
   - `Iperf3` can run multiple concurrent connections, potentially showing higher bandwidth capacities compared to `speedtest-cli`.

## 3. Find which process is using the port

```shell
sudo lsof -i :8080
```

1. **lsof**: Stands for "list open files." The `lsof` command is used to list currently open "files," where in this context, a network port is also considered a "file."

2. **-i**: This is an option for the `lsof` command that restricts the output to only show information related to network connections.

3. **:8080**: Specifies the port number to examine. Here, `:8080` indicates port number 8080.
