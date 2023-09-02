---
title: Primary Key
date: 2023-07-12 08:58:36
categories:
 - database
tags:
 - database
---

## Primary Key

### Index

Indexes are used to find rows with specific column values quickly. Without an index, MySQL must begin with the first row and then read through the entire table to find the relevant rows. The larger the table, the more this costs. If the table has an index for the columns in question, MySQL can quickly determine the position to seek to in the middle of the data file without having to look at all the data. This is much faster than reading every row sequentially.

Any column in creating table statement declared as `PRIMARY KEY`, `KEY`, `UNIQUE`or `INDEX` will be indexed automatically by MySQL. Most MySQL indexes (PRIMARY KEY, UNIQUE, INDEX, and FULLTEXT) are stored in [B-trees](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_b_tree). 

### Clustered and Secondary Indexes

Each InnoDB table has a special index called the clustered index that stores row data. Typically, the clustered index is synonymous with the primary key. To get the best performance from queries, inserts, and other database operations, it is important to understand how InnoDB uses the clustered index to optimize the common lookup and DML operations.

1. When you define a `PRIMARY KEY` on a table, **InnoDB** uses it as the **clustered index**. **A primary key should be defined for each table**. If there is no logical unique and non-null column or set of columns to use a the primary key, add an auto-increment column. Auto-increment column values are unique and are added automatically as new rows are inserted.

2. If you do not define a `PRIMARY KEY` for a table, **InnoDB** uses the first `UNIQUE index` with all key columns defined as NOT NULL as the clustered index.
   1. If a table has no `PRIMARY KEY` or suitable `UNIQUE index`, InnoDB generates a hidden clustered index named `GEN_CLUST_INDEX` on a synthetic column that contains row ID values. The rows are ordered by the row ID that InnoDB assigns. The row ID is a 6-byte field that increases monotonically as new rows are inserted. Thus, the rows ordered by the row ID are physically in order of insertion.


从以上可以看出, Clustered Indexe就是你用pk修饰的那一列, 比如ID, 然后创建表的时候就应该设置PK在使用MySQL的时候, 然后这些PK(唯一标识行)以B-Tree的结构被InnoDB Engine组织用于快速查找而不是笨笨的一行一行的遍历. 如果你不声明PK或者Unique的列, 那InnoDB只好自动帮你创建一个PK(implicitly, hidden form you).

### Should Each Table Have a Primary Key?

Short answer: yes, each table should have a PRIMARY KEY so that you could distinguish two records. 

In MySQL, the **InnoDB storage engine** always creates a primary key if you didn't specify it explicitly, thus making an extra column you don't have access to.

参考:

- [MySQL 8.0 Reference Manual :: 8.3.1 How MySQL Uses Indexes](https://dev.mysql.com/doc/refman/8.0/en/mysql-indexes.html)

- [The Benefits of Indexing Large MySQL Tables](https://www.drupal.org/docs/7/guidelines-for-sql/the-benefits-of-indexing-large-mysql-tables) 需要取消ad blocker才能访问

- [MySQL 8.0 Reference Manual :: 15.6.2.1 Clustered and Secondary Indexes](https://dev.mysql.com/doc/refman/8.0/en/innodb-index-types.html)