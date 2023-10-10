---
title: Nginx
date: 2023-10-09 14:01:50
categories:
 - build website
tags:
 - build website
 - cs basics
---

## 1. Common used commands

```shell
$ sudo apt install nginx
# check if nginx is running
$ systemctl status nginx 
# stop nginx service
$ sudo systemctl stop nginx
# start nginx service
$ sudo systemctl start nginx
# restart
$ sudo systemctl restart nginx
# make configuration changes, Nginx can reload without dropping connections:
$ sudo systemctl reload nginx
```

By default, Nginx is configured to start automatically when the server boots. If this is not what you want, you can disable this behavior by typing:

```shell
$ sudo systemctl disable nginx
```

To re-enable the service to start up at boot, you can type:

```shell
$ sudo systemctl enable nginx
```

## 2. Why use Nginx

If you stop nginx service and there is no other web server is running on your server (listening and responding `80` port), then when you browse `http://your_server_ip`, it will timeout. 

```shell
$ sudo systemctl stop nginx
```

If you start nginx service, then when you browse `http://your_server_ip`, you will get a welcome to Nginx web page. 

```shell
$ sudo systemctl start nginx
```

## 3. Use cases of Nginx

Load Balancing: Nginx can distribute incoming HTTP requests across multiple backend servers to achieve load balancing. For example, if you have multiple web servers running on different AWS EC2 servers, Nginx can evenly distribute incoming requests among them, improving overall performance and ensuring high availability.

[Reverse Proxy](https://www.youtube.com/watch?v=RXXRguaHZs0): Nginx can act as a reverse proxy, receiving HTTP requests from clients and forwarding them to backend servers. This provides an additional layer of security by hiding the internal server details and allowing you to perform tasks such as SSL termination, caching, and request filtering. 

> A **reverse proxy** is a method used to achieve **load balancing**, which is the ultimate objective. Load balancing, however, can also be accomplished using alternative methods apart from a reverse proxy.

## 4. Config Nginx

### 4.1. Setting up virtual servers

A virtual server is defined by a `server` directive in the `http` context, it is possible to add multiple `server` in the `http` context to define multiple virtual servers. for example:

```nginx
http {
    server {
        # Server configuration
    }
    
    server {
        # Server configuration
    }
}
```

The `server` configuration block usually includes a [listen](https://nginx.org/en/docs/http/ngx_http_core_module.html#listen) directive to specify the IP address and port (or Unix domain socket and path) on which the server listens for requests. Both IPv4 and IPv6 addresses are accepted; enclose IPv6 addresses in square brackets.

The example below shows configuration of a server that listens on IP address 127.0.0.1 and port 8080:

```nginx
server {
    listen 127.0.0.1:8080;
    # Additional server configuration
}
# or
server {
    listen      80;
    server_name example.org www.example.org;
    #...
}
```

### 4.2. Example

`server`: The `server directive` is used to define the configuration for a virtual server. It specifies the domain name, IP address, and port on which the server will listen for incoming requests. You can have multiple server blocks in the http context to define different virtual servers with their own configurations.

`location`: The `location directive` is used to define how Nginx handles requests for specific URL patterns. 

`upstream`: The `upstream directive` is used to define a group of servers that Nginx can distribute requests to. It is primarily used for configuring load balancing. 

To demonstrate, I wrote a coplicated example:

```nginx
http {
    upstream my_servers {
          server localhost:8087 weight=10;
          server localhost:8088 weight=2;
          server localhost:8089;
    }

    server {
        #listen 80;
        #server_name example.com; # or ip
    		listen localhost:80;

        location / {
            root /var/www/html;
            index index.html;
            proxy_pass http://my_servers; # 'my_servers' is the name of upstream
        }
    }
}
```

You can write a simpe `server` add it into the `http` in `nginx.conf`: 

```nginx
server {
      #listen 80;
      #server_name example.com; # or ip
      listen localhost:80;

      location / {
          root /var/www/html;
          index index.html;
      }
}
```

```shell
$ nginx -s reload
```

Then you need add a simple html file under the root path of this server which is  `/var/www/html` we defined above, then you can access the webpage that you wrote at`/var/www/html/index.html` by browse `http://18.209.22.189/`. Because the port is 80 we don't need to prevode in url here. 

> Note: if cannot access, don't forget to check your firewall, both uwf and ec2 security group if your server is running on AWS. 

{{% youtube "sCJcusORiE8" %}}

Video: https://youtu.be/sCJcusORiE8?si=OFtCDNu-3gbkiy3_

References:

- https://juejin.cn/post/6844904106541203464
- [How To Install Nginx on Ubuntu 20.04 | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-20-04)

