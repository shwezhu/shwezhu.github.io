---
title: AWS EC2 - Basic Settings of a Server
date: 2023-09-09 15:53:57
categories:
 - build website
tags:
 - aws
 - build website
---

```shell
# Change password of supervisor
$ sudo passwd ubuntu
```

## 1. Connect to EC2 Instance

```shell
$ ssh -i aws-key.pem root@your-ec2-ip-address
The authenticity of host 'xx.xx.xx.xx' can't be established.
ED25519 key fingerprint is SHA256:UULuI08gIJRb+vQnFPpjcSW7hAtLIgf5g.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes 
Warning: Permanently added 'xx.xx.xx.xx' (ED25519) to the list of known hosts.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@         WARNING: UNPROTECTED PRIVATE KEY FILE!          @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Permissions 0644 for 'aws-key.pem' are too open.
It is required that your private key files are NOT accessible by others.
This private key will be ignored.
Load key "aws-key.pem": bad permissions
root@xx.xx.xx.xx: Permission denied (publickey).
```

### 1.1. “UNPROTECTED PRIVATE KEY FILE!” Error

The “UNPROTECTED PRIVATE KEY FILE!” error occurs when the permissions on your private key file are too permissive. Specifically, it means that the file is readable and/or writable by other users or processes on your system.

To understand why this is a problem, it’s important to understand how SSH keys work. When you create an SSH key pair, you generate two files: a public key and a private key. **The public key is stored on the Amazon EC2 instance, while the private key is stored on your local machine**.

When you attempt to log in to the Amazon EC2 instance using SSH, your local machine sends a request to the instance. The instance responds by sending a challenge message that can only be decrypted using the private key associated with the public key stored on the instance. If your local machine is able to decrypt the challenge message, then you’re granted access to the instance.

However, if the permissions on your private key file are too permissive, then other users or processes on your system may be able to access the file and use it to decrypt the challenge message. This is a security risk, as it means that your private key is no longer private.

```shell
$ ls -all
-rw-r--r--@  1 David  staff   1674  8 Sep 23:54 aws-key.pem
```

- The first character "-" indicates that it is a regular file.
- The following three characters "rw-" represent the owner's permissions: read (r) and write (w) are allowed, while execute (-) permission is not granted.
- The next three characters "r--" represent the group permissions: only read permission is allowed.
- The final three characters "r--" represent the permissions for others (users not in the owner or group): only read permission is allowed.

Learn more: https://saturncloud.io/blog/unprotected-private-key-file-error-using-ssh-into-amazon-ec2-instance-aws/#what-causes-the-unprotected-private-key-file-error

### 1.2. Fix error

This will change the permissions on the file so that only the owner (i.e., you) can read and write to it. 

```shell
$ chmod 400 aws-key.pem
$ ls -all
-r--------@  1 David  staff   1674  8 Sep 23:54 aws-key.pem
```

### 1.3. Verify

```shell
$ ssh -i aws-key.pem root@xx.xx.xx.xx
Please login as the user "ubuntu" rather than the user "root".

$ ssh -i aws-key.pem ubuntu@xx.xx.xx.xx
# success ...
```

## 2. Login

### 2.1. Login without using keypairs from aws

Copy your ssh public key on your computer into the `~/.ssh/authorized_keys` file on you EC2 instance. 

On you loacl machine:

```shell
$ cat ~/.ssh/id_rsa.pub 
...
```

Copy the content into your EC2 instance:

```shell
$ sudo vi .ssh/authorized_keys
```

Then you can login directly:

```shell
$ ssh ubuntu@xx.xx.xx.xx
```

### 2.2. Recommend ways

Here's what I did on a `Ubuntu EC2`:

**A) Login as root using the keypairs**

**B) Setup the necessary users and their passwords with**

```shell
$ sudo adduser USERNAME
```

**C) Edit `/etc/ssh/sshd_config` setting**

For a valid user to login with no key:

```
PasswordAuthentication yes
```

D) Restart the `ssh` daemon with

```shell
$ sudo service ssh restart
```

Just change ssh to sshd if you are using centOS, Now you can login into your `ec2` instance without key pairs.

> **NOTE**: you should edit `/etc/ssh/sshd_config` not `/etc/ssh/ssh_config` file. 

Difference between these two files: 

Source: https://stackoverflow.com/a/7696451/16317008

## 3. Set up oh-my-zsh shell

```shell
sudo apt install zsh -y
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
```

