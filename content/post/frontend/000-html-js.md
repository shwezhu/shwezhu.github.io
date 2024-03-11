---
title: HTML Basics
date: 2024-03-07 20:02:10
categories:
 - front-end
tags:
 - front-end
---

## `e.preventDefault()`

```js
function sendMessage(e) {
    e.preventDefault()  // Submitting form would refresh the page, so we prevent page reload
    const input = document.querySelector('input')
    if (input.value) {
        ws.send(input.value)
        input.value = ""
    }
    input.focus()  // Focus the input after sending the message
}

document.querySelector('form').addEventListener('submit', sendMessage)
```

> Usually used to prevent page reload when submit form.

## `defer` attribute of `<script>`

```html
<head>
    <meta charset="UTF-8">
    <title>Chat APP</title>
    <script defer src="js/app.js"></script>
</head>
<body>
  ...
```

> A boolean value used to execute the script only after the browser completes the rendering activity. 
>
> **Note:** The `defer` attribute can only be used when JavaScript is externally linked to the HTML file using the `src` attribute of the `<script>` tag. 

## `innerHTML` property

**innerHTML** is a property of every element. It tells you what is between the starting and ending tags of the element, and it also let you sets the content of the element.

```html
<p class="myp"><a>hello hi ni</a></p>

<script>
  const myp = document.querySelector('.myp')
  console.log(myp.innerHTML)
</script>
```

This will print a stirng: 

```
<a>hello hi ni</a>
```

The `innerHTML` property is part of the Document Object Model (DOM) that allows Javascript code to manipulate a website being displayed. Specifically, it allows reading and replacing everything within a given DOM element (HTML tag).



References:

- [What is the use of the defer attribute in the HTML <script> tag?](https://www.educative.io/answers/what-is-the-use-of-the-defer-attribute-in-the-html-script-tag)