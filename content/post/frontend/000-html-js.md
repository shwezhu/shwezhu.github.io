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





References:

- [What is the use of the defer attribute in the HTML <script> tag?](https://www.educative.io/answers/what-is-the-use-of-the-defer-attribute-in-the-html-script-tag)