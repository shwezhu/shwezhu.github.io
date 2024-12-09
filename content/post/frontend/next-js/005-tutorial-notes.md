---
title: Tutorial Notes Next.js
date: 2024-12-07 18:20:22
tags:
 - front-end
---

**UUIDs vs. Auto-incrementing Keys**

> We use UUIDs instead of incrementing keys (e.g., 1, 2, 3, etc.). This makes the URL longer; however, UUIDs eliminate the risk of ID collision, are globally unique, and reduce the risk of enumeration attacks - making them ideal for large databases.
>
> However, if you prefer cleaner URLs, you might prefer to use auto-incrementing keys.
>
> [source](https://nextjs.org/learn/dashboard-app/mutating-data)













Source: https://nextjs.org/learn/dashboard-app/mutating-data