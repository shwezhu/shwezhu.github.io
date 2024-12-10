---
title: npm vs npx vs pnpm
date: 2024-12-08 15:20:22
tags:
 - front-end
---

### npm vs npx vs pnmp

```bash
# download and install Node.js
# https://nodejs.org/en/download/package-manager
brew install node@22
node -v # should print `v22.12.0`
npm -v # should print `10.9.0`

# install pnpm
# https://pnpm.io/installation
curl -fsSL https://get.pnpm.io/install.sh | sh -
```

`npm` comes with `Node.js`, and `npx` comes with `npm`. **In order to use `npm` or `npx`, you need install `node.js`.**   

```
Node.js installation
└── includes npm (Node Package Manager)
└── includes npx (Node Package Execute)
```

```bash
npx create-react-app my-app
npm install some-package
```

- NPM is a package manager for node.js, same as `pip` for python, `pnmp` is same as `npm`, but more efficient
- npx 是 npm 的一个工具, 它允许我们直接运行 npm 包中的命令行工具, 而不需要全局安装这些工具
- `create-next-app@latest`: 是 Next.js 官方提供的脚手架工具(scaffolding tool), create-next-app 是工具的名称, @latest 表示使用最新版本

举个例子来说明 npx 的作用:

```bash
# 不使用 npx 的话,我们需要先全局安装
npm install -g create-next-app
create-next-app my-project

# 使用 npx,可以直接运行而不需要安装
npx create-next-app@latest my-project
```

----

### **pnpm use case in real world**

```bash
# 开发模式
$ pnpm run dev    # 启动开发服务器，实时编译，方便开发

# 生产模式
$ pnpm run build  # 构建优化后的生产环境代码
$ pnpm start      # 启动生产环境服务器
```

`pnpm run` is a command, and `dev`, `build`, and `start` are scripts/commands defined in your project's `package.json` file. 

Here's how a typical package.json might look:

```json
{
  "name": "your-project",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start"
  }
}
```

You can try add a custom scripts to package.json, like:

```json
"scripts": {
  //...
  "custom": "echo 'my custom script'"
}
```

Then run: `pnpm run custom`

---

### folder structure of next.js project 

```
$ tree -a -L 1              
├── .next     # Auto-generated build output directory, created after running next build
├── next.config.ts       # Next.js configuration file in TypeScript
├── node_modules         # Dependencies installed by package manager (pnpm in this case)
├── package.json         # Project metadata and dependencies
├── public              # Static files served at runtime (images, fonts, etc.)
....
```

---

### learn to understand warnings

```bash
$ pnpm i @vercel/postgres
WARN Issues with peer dependencies found
.
└─┬ next 15.0.0
  ├── ✕ unmet peer react@"^18.2.0 || 19.0.0-rc-65a56d0e-20241020": found 19.0.0-rc-cd22717c-20241013
  └── ✕ unmet peer react-dom@"^18.2.0 || 19.0.0-rc-65a56d0e-20241020": found 19.0.0-rc-cd22717c-20241013
Done in 1.2s
```

- "peer dependencies" 通常翻译为"同级依赖", 它表示一个包要求宿主环境中必须安装特定的其他包才能正常工作, 举个例子：如果你安装一个 React 组件库, 若它将 React 列为 peer dependency, 这意味着这个组件库期望你的项目中已经安装了 React, 而不是它自己携带一个 React 副本
- `unmet peer react@"^18.2.0 || 19.0.0-rc-65a56d0e-20241020": found 19.0.0-rc-cd22717c-20241013`: 这个包（Next.js）要求项目使用的 React 版本必须是：应该为 18.2.0 或更高的 18.x 版本（ `^18.2.0` ）或者是特定的 RC 版本 `19.0.0-rc-65a56d0e-20241020`, 但是在项目中找到的是另一个 RC 版本：`19.0.0-rc-cd22717c-20241013`, 版本不匹配，所以系统发出警告