---
title: React Basics
date: 2023-12-20 19:44:22
categories:
 - react
tags:
 - react
---


```js
npm create vite@latest name-of-your-project -- --template react
# follow prompts
cd <your new project directory>
npm install react-router-dom localforage match-sorter sort-by
npm run dev
```

## 1. Conponents rendering

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

```jsx
export default function Root() {
    console.log("root");

    const [name, setName] = useState('');
    function handleNameChange(event) {
        setName(event.target.value);
    }

    return (
          <input
              type="text"
              value={name}
              onChange={handleNameChange}
          />
    );
}

// console.log("root") get executed everytime when you input something into the <input>
// you can use useEffect() hook to prevent this behavior.
```

[Why is my function being called twice in React?](https://stackoverflow.com/questions/50819162/why-is-my-function-being-called-twice-in-react)

> When developing in “Strict Mode”, React calls each component’s function twice, which can help surface mistakes caused by impure functions. [Source](https://react.dev/learn/render-and-commit)

Learn more: [Render and Commit – React](https://react.dev/learn/render-and-commit)

## 2. useNavigate

root.jsx:8 You should call navigate() in a React.useEffect(), not when your component is first rendered.

The warning message you're seeing suggests that you are calling `navigate()` directly during the initial render of your component, which is not the recommended practice in React. Instead, you should use `navigate()` within an effect (`React.useEffect`) or as a response to user interactions, like a button click.

1. The condition `!posts` will be true for both `null` and `undefined`, covering the case where `posts` is not defined. It also covers empty strings, `false`, and `0`, though these cases are less likely based on your context.
2. In JavaScript, if you want to check whether a variable `a` is either `null` or `undefined`, you can simplify the condition using the `==` operator instead of the `===` operator. The `==` operator performs type coercion and treats `null` and `undefined` as equal. 

In your current code, the `catch()` block is designed to catch errors that occur during the `fetch` request or in the initial part of the `.then()` chain. However, it doesn't catch errors that occur within the nested `.then()` where you are calling `res.json()`.

```js
async function getPosts(numPosts) {
    return await Post.find().limit(numPosts);
    // good: return Post.find().limit(numPosts);
}
```

Using `return await` inside an async function is redundant when returning the result directly. You can simply return the Promise itself, which is more efficient. The `await` keyword is useful when you need the resolved value for some processing within the function, but if you're just passing the promise along, you can return it directly.

```js
async function getPosts(numPosts) {
    return Post.find().limit(numPosts);
}

async function handleGetPosts(req, res) {
    // here is wrong, same as above example
    const posts = await getPosts(10);
    posts
    .then(
        (docs) => {
            res.status(200).json(docs);
        })
    .catch(
        (err) => {
            res.status(500).json({message: `internal error: ${err}`});
        }
    );
}

// Why I get TypeError: posts.then is not a function
```

The issue in your code is that you're using `await` incorrectly with the `getPosts` function. When you use `await`, it waits for the promise to resolve and returns the result directly. Therefore, `posts` in your code is not a promise but the actual result of the promise. This is why you're getting a "TypeError: posts.then is not a function" because `posts` is an array (or whatever `getPosts` returns), not a promise.

```js
async function handleGetPosts(req, res) {
    try {
        const posts = await getPosts(10);
        res.status(200).json(posts);
    } catch (err) {
        res.status(500).json({message: `internal error: ${err}`});
    }
}
```


When you use multiple instances of the same component, each instance maintains its own independent state. This means if you have a `<Counter />` component, for example, and you use it three times in your app (there are three `<Counter />`), each `<Counter />` will have its own separate count state.

In React, state updates may be asynchronous for performance reasons. This means after calling the state update function, the updated state might not be immediately reflected.

```js
function Counter() {
  const [count, setCount] = useState(0);

  const handleClick = () => {
    setCount(count + 1);
    console.log(count); // This may not log the updated count
  };

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={handleClick}>Increment</button>
    </div>
  );
}
```

In this example, if you click the button, you might expect the console.log statement to print the updated count. However, due to the asynchronous nature of state updates, it might still show the previous count. This is because setCount doesn't update the count variable immediately.

```js
const handleClick = () => {
  setCount(prevCount => {
    const updatedCount = prevCount + 1;
    console.log(updatedCount); // Correctly logs the updated count
    return updatedCount;
  });
};
```
