---
title: Tailwind CSS Commonly Used Class
date: 2024-01-06 12:46:22
categories:
 - front-end
tags:
 - front-end
typora-root-url: ../../../static
---

设置 Tailwind CSS: 

https://tailwindcss.com/docs/installation

```js
// tailwind.config.js
module.exports = {
  // ./src/index.html, /src/pages/about.html 等等都会被匹配到
  content: ["./src/**/*.{html,js}"],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

----

block 元素水平居中: `mx-auto`, 注意对 inline 无效, 原因: `margin-left: auto`, `margin-right: auto` 无法适用 inline 元素.

```
<nav className="fixed bottom-0 left-0 right-0 z-50 bg-white dark:bg-gray-900 border-t dark:border-gray-800 safe-area-pb">
            <div className="mx-auto px-4 max-w-lg">
                <div className="flex justify-around items-center h-16">
                	<Link>
                		...
                	</Link>
                	<Link>
                		...
                	</Link>
                	<Link>
                		...
                	</Link>
                	....
```



## 响应式

### 导航栏

```html
<div>
    <div className="mx-auto px-4 w-full max-w-7xl border-2">
        <div className="flex justify-around items-center">
            <Link href="/" className="text-blue-600 dark:text-blue-400">首页</Link>
            <Link href="/discuss" className="text-blue-600 dark:text-blue-400">讨论</Link>
            <Link href="/search" className="text-blue-600 dark:text-blue-400">搜索</Link>
        </div>
    </div>
</div>
```

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/12/a3f08d9ac96f269da225d22fa7b5bda3.png)

> `max-w-7xl` 限制最大宽度在 7xl 以内, 注意 `w-full` 并不多余, 因为盒子可能不会自动占满整个宽度, 它确保了容器行为的可预测性
>
> 水平方向: `justify-around` 控制 flex 子元素在主轴（默认是水平方向）上的分布, 子元素会平均分布，每个元素两侧有相等的空间, 与 `justify-between` 的区别是, `around` 在两端也会留有空间（约为中间空间的一半）
>
> 垂直方向居中: `items-center`: 控制 flex 子元素在交叉轴（默认是垂直方向）上的对齐方式

```

// page.tsx
import { notFound } from 'next/navigation';
import { posts, comments, users } from '../_data/mockData';
import type { Comment } from '../_data/mockData';
import CommentCard from "@/app/discuss/_components/CommentCard";


// 定义页面参数类型
interface PostPageProps {
    params: {
        postId: string;
    };
}

// 帖子详情页面组件
export default function PostPage({ params }: PostPageProps) {
    // 根据 postId 查找帖子
    const post = posts.find((p) => p.id === params.postId);

    // 如果帖子不存在，返回 404
    if (!post) {
        notFound();
    }

    // 查找帖子作者信息
    const author = users.find((u) => u.id === post.authorId);

    // 查找该帖子的所有评论
    const postComments = comments.filter((c) => c.postId === post.id);

    return (
        <div className="max-w-4xl mx-auto p-4">
            {/* 帖子标题 */}
            <h1 className="text-3xl font-bold mb-4">{post.title}</h1>

            {/* 帖子信息 */}
            <div className="flex items-center gap-4 mb-6 text-gray-600">
                <span>作者: {author?.name}</span>
                <span>发布时间: {new Date(post.createdAt).toLocaleString()}</span>
                <span>点赞数: {post.likesCount}</span>
            </div>

            {/* 帖子内容 */}
            <div className="prose max-w-none mb-8">
                <p>{post.content}</p>
            </div>

            {/* 评论区 */}
            <div className="mt-8 pb-20">
                <h2 className="text-2xl font-bold mb-4">评论 ({postComments.length})</h2>
                <div className="space-y-4">
                    {postComments.map((comment) => (
                        <CommentCard key={comment.id} comment={comment} />
                    ))}
                </div>
            </div>
        </div>
    );
}

---------------------------------------------

// CommentCard.tsx
import Image from 'next/image';
import { HeartIcon, ReplyIcon, TrashIcon } from 'lucide-react';
import { Comment, User, comments } from '../_data/mockData';

interface CommentCardProps {
    comment: Comment;
    currentUserId: string;     // 当前登录用户ID
    users: User[];            // 传入用户列表，用于查找用户信息
    onLike: (commentId: string) => void;
    onReply: (commentId: string) => void;
    onDelete: (commentId: string) => void;
}

export function CommentCard({
                                comment,
                                currentUserId,
                                users,
                                onLike,
                                onReply,
                                onDelete
                            }: CommentCardProps) {
    // 查找评论作者信息
    const author = users.find(u => u.id === comment.authorId);

    // 如果是回复评论，查找原评论的作者信息
    const parentAuthor = comment.parentId
        ? users.find(u => u.id === users.find(u =>
            comments.find(c => c.id === comment.parentId)?.authorId === u.id
        )?.id)
        : null;

    // 检查是否是评论作者（用于显示删除按钮）
    const isAuthor = currentUserId === comment.authorId;

    return (
        <div className="bg-white rounded-lg shadow-sm p-4">
            <div className="flex gap-3">
                {/* 用户头像 */}
                <Image
                    src={author?.avatar || '/default-avatar.png'}
                    alt={author?.name || '用户'}
                    width={40}
                    height={40}
                    className="rounded-full"
                />

                <div className="flex-1">
                    {/* 用户信息和时间 */}
                    <div className="flex justify-between items-start">
                        <div>
                            <h4 className="font-semibold">{author?.name}</h4>
                            <span className="text-gray-500 text-sm">
                                {new Date(comment.createdAt).toLocaleString()}
                            </span>
                        </div>

                        {/* 删除按钮 - 仅评论作者可见 */}
                        {isAuthor && (
                            <button
                                onClick={() => onDelete(comment.id)}
                                className="text-gray-400 hover:text-red-500 transition-colors"
                                title="删除评论"
                            >
                                <TrashIcon size={16} />
                            </button>
                        )}
                    </div>

                    {/* 评论内容 - 如果是回复则显示@用户 */}
                    <p className="mt-2 text-gray-800">
                        {parentAuthor && (
                            <span className="text-blue-500 mr-1">
                                @{parentAuthor.name}{' '}
                            </span>
                        )}
                        {comment.content}
                    </p>

                    {/* 操作按钮 */}
                    <div className="mt-3 flex items-center gap-4">
                        <button
                            onClick={() => onLike(comment.id)}
                            className={`flex items-center gap-1 ${
                                comment.isLiked ? 'text-red-500' : 'text-gray-500'
                            }`}
                        >
                            <HeartIcon size={16} />
                            <span>{comment.likesCount}</span>
                        </button>
                        <button
                            onClick={() => onReply(comment.id)}
                            className="flex items-center gap-1 text-gray-500"
                        >
                            <ReplyIcon size={16} />
                            <span>回复</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
}

export default CommentCard;


----------------------------------

// app/discuss/_data/types.ts
export interface User {
    id: string;
    name: string;
    avatar: string;
}

export interface Comment {
    id: string;
    postId: string;
    authorId: string;
    content: string;
    createdAt: string;
    likesCount: number;
    parentId?: string;        // 保留parentId用于标识回复关系
    replyToUser?: User;       // 新增：存储被回复用户信息，方便显示
    isLiked?: boolean;
}

export interface Post {
    id: string;
    title: string;
    content: string;
    authorId: string;
    createdAt: string;
    likesCount: number;
    commentsCount: number;
    isLiked?: boolean;
}
```





----

**宽度（Width）**:

- `w-1/2`元素宽度为容器宽度的 50%, `w-4 `元素宽度为 1rem（默认情况下，所有的尺寸都基于 4 倍体系）, `w-full` 元素宽度为 100%

**高度（Height）**:

`h-10` 高度为 2.5rem, `h-screen`高度为视口的高度, 这里和高度为100%也是有区别的, 100%的时候放到手机上, 可能会出现整个页面比手机高, 而不是刚刚好

**内边距（Padding）**:

 `px-`、`py-`、`pt-`、`pb-`、`pl-`、`pr-` , 例如：`p-4` 所有方向的内边距都是 1rem, `px-2`水平方向（左右）的内边距是 0.5rem

**外边距（Margin）**:

 `mx-`、`my-`、`mt-`、`mb-`、`ml-`、`mr-` 例如：`m-5`所有方向的外边距都是 1.25rem,`mt-3` 上方外边距是 0.75rem

----
