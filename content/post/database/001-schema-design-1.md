---
title: Design of Database Schema
date: 2024-01-04 17:51:35
categories:
 - database
tags:
 - database
 - mongodb
---

## 1. Post Schema

### 1.1. Likes Field

> The limit of the **document** in **MongoDB** is 16mb, which is pretty huge. Unless you're trying to create the next Facebook, putting the IDs in the array won't be an issue. I have production workflows with 10k+ IDs in a single document array, have no issues. [source](https://stackoverflow.com/a/45041781/16317008)

