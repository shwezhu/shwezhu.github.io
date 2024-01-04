---
title: React Basics & Deployment
date: 2023-12-20 19:44:22
categories:
 - front-end
tags:
 - front-end
---

## 1. Create project with Vite

```js
npm create vite@latest name-of-your-project -- --template react
cd <your new project directory>
npm install react-router-dom localforage match-sorter sort-by
npm run dev/npm run build
```

The Proxy in vite.config.js just works for development mode. In production mode it doesn't work.

The production mode means you run `npm run build` which will generate a `dist` folder. Then you can deploy that folder into your server. 


## 2. Deploy to server

```js
scp -rp dist/ root@149.28.30.20:/var/www/html/
```

Then follow this: [Nginx - David's Blog](https://davidzhu.xyz/post/build-website/007-nginx/)

## 3. Conponents rendering

This process of requesting and serving UI has three steps:

- **Triggering** a render
  - Initial render.
  - Re-renders when state updates, (or one of its ancestors’) state has been updated. Once the component has been initially rendered, you can trigger further renders by updating its state with the [`set` function.](https://react.dev/reference/react/useState#setstate)
  
- **Rendering** the component
  - After you trigger a render, React calls your components to figure out what to display on screen. ***“Rendering” is React calling your components.***
  - The process of rendering is recursive. 
  
- React **commits** changes to the DOM
  - React will apply the minimal necessary operations (calculated while rendering!) to make the DOM match the latest rendering output. 
  - Think the clock and input example. 


> The default behavior of rendering all components nested within the updated component is not optimal for performance if the updated component is very high in the tree. If you run into a performance issue, there are several opt-in ways to solve it described in the [Performance](https://reactjs.org/docs/optimizing-performance.html) section. **Don’t optimize prematurely!**

> When developing in “Strict Mode”, React calls each component’s function twice, which can help surface mistakes caused by impure functions. [Source](https://react.dev/learn/render-and-commit)

Learn more: [Render and Commit – React](https://react.dev/learn/render-and-commit)
