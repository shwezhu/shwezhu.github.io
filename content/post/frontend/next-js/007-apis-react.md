---
title: APIs React - Next.js
date: 2024-12-14 21:20:32
tags:
 - front-end
---

## React.memo()

### What is it?

`memo` lets you skip re-rendering a component when its props are unchanged

```ts
const MemoizedComponent = React.memo(SomeComponent, arePropsEqual?)
```

It takes your original component as an input, and returns a new component with added optimization logic, which makes this new component will check if props changed before re-rendering.

> There is a rule you should always keep in mind: React components will always re-render when their parent re-renders.

### Tips

Using memo on components with frequently changing props actually creates extra overhead - you're paying the cost of props comparison while still ending up with a re-render anyway.

Memo should be treated as a performance optimization tool, not a default coding practice.

You should first identify actual performance issues through profiling, then apply memo strategically where needed, rather than using it everywhere. This aligns with the engineering principle that '**premature optimization is the root of all evil**'.

