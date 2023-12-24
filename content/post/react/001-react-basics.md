---
title: React Basics
date: 2023-12-20 19:44:22
categories:
 - react
tags:
 - react
---

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

## 2. Common hooks

### 2.1. useEffect

#### 2.1.1. What is useEffect

`useEffect` is a React Hook that lets you [synchronize a component with an external system.](https://react.dev/learn/synchronizing-with-effects)

```jsx
useEffect(setup, dependencies?)
```

By default, your Effect will run **after every render**.

- **No Dependency (No Array)**: If you don’t provide the second argument (the array), the effect runs after every rendering.
- **Empty Array (`[]`)**: If you pass an empty array, the effect runs **once after the initial rendering**. This is similar to `componentDidMount` in class components.
- **With Dependencies**: If you include values in the array, the effect will rerun when any of those values change. This is used for effects that should react to specific state changes or prop updates.

#### 2.1.2. How to remove unnecessary Effects

- Let’s say you want to filter a list before displaying it. You might feel tempted to write an Effect that updates a state variable when the list changes. However, this is inefficient. When you update the state, React will first call your component functions to calculate what should be on the screen. Then React will [“commit”](https://react.dev/learn/render-and-commit) these changes to the DOM, updating the screen. Then React will run your Effects. If your Effect *also* immediately updates the state, this restarts the whole process from scratch! To avoid the unnecessary render passes, transform all the data at the top level of your components. **That code will automatically re-run whenever your props or state change.**
- **You don’t need Effects to handle user events.** For example, let’s say you want to send an `/api/buy` POST request and show a notification when the user buys a product. In the Buy button click event handler, you know exactly what happened. By the time an Effect runs, you don’t know *what* the user did (for example, which button was clicked). This is why you’ll usually handle user events in the corresponding event handlers.

#### 2.1.3. Update state in useEffect without setting dependency

useEffect hook will be called after component rendering,  a state of the component updating will trigger the render of component, so if we update the state of a component, will this cause a loop?

Updating a component's state within a `useEffect` hook can indeed cause a loop, but this depends on how you've set up the effect and its dependency array.

Learn more: 

- [useEffect – React](https://react.dev/reference/react/useEffect)
- [Synchronizing with Effects – React](https://react.dev/learn/synchronizing-with-effects)
- [You Might Not Need an Effect – React](https://react.dev/learn/you-might-not-need-an-effect)

## 3. Lifecycle





## 4. useNavigate

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

