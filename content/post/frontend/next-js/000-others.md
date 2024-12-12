---
title: Next.js Notes
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

---

```ts
type SortOption = 'latest' | 'hot' | 'mostLiked';

// 不推荐, 若代码没有使用所有选项, 编译器会警告未使用变量, 其实是使用了, 只不过在运行时才能确定, 但编译器不知道, 不利于多人维护, 比如人家看没有使用的变量, 直接就删除了, 但用户通过点击选项来选择排序, 这是运行时才能确定的
const sortFunctions = React.useMemo(() => ({
    latest: (a: Post, b: Post) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime(),
    hot: (a: Post, b: Post) => (b.likesCount * 2 + b.commentsCount) - (a.likesCount * 2 + a.commentsCount),
    mostLiked: (a: Post, b: Post) => b.likesCount - a.likesCount
}), []);

// 解决办法, 指定 key 的类型
const sortFunctions: Record<SortOption, (a: Post, b: Post) => number> = React.useMemo(() => ({
    latest: (a: Post, b: Post) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime(),
    hot: (a: Post, b: Post) => (b.likesCount * 2 + b.commentsCount) - (a.likesCount * 2 + a.commentsCount),
    mostLiked: (a: Post, b: Post) => b.likesCount - a.likesCount
}), []);
```

> `Record<K, V>` 是 TypeScript 的一个工具类型, K 是键的类型, V 是值的类型
>
> 类似 map, 但这里更适合用 Record, 因为 key 类型固定, 不需要动态增删排序... 而且, 访问方式也不一样, Record 更直观:
>
> `const sortFn = sortFunctions.latest` / `const sortFn = sortFunctionsMap.get('latest')`

----

