---
title: HTML Basics
date: 2024-03-07 20:02:10
categories:
 - front-end
tags:
 - front-end
---

## 1. `e.preventDefault()`

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

## 2. `defer` attribute of `<script>`

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

## 3. `innerHTML` property

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

## 4. Ways to Get Form Element Value

```html 
<form id="registerForm">
    <input type="text" id="regUsername" name="regUsername" placeholder="Username" required>
    <input type="password" id="regPassword" name="regPassword" placeholder="Password" required>
    <button type="submit">Register</button>
</form>

<script>
  const registerForm = document.getElementById('registerForm')

  registerForm.addEventListener('submit', async (e) => {
      e.preventDefault()
      // 1. Form elements must have a name attribute to be accessed this way.
      const formData = {
          username: registerForm.regUsername.value,
          password: registerForm.regPassword.value,
      }
      // 2. Get data by Id
      const username = document.getElementById('regUsername').value;
      const password = document.getElementById('regPassword').value;
      const formData = {...}
      // 3. Use form directly
      const formData = new FormData(registerForm);
      ...
</script>
```

Note: `FormData()`, if input is empty and the type is string, it will be empty string. So I mean the key will still be included in the form data. The key is the name attribute of the input element.

So `FormData` is concise to form data, but it has downsides, that it has all key-value even the input value is empty. 

But sometimes you have to use it when you want sends data as `multipart/form-data`. The first two methods is used for simple `application/json` data transfer. 

```js
registerForm.addEventListener('submit', async (e) => {
    e.preventDefault();

    const username = registerForm.regUsername.value;
    const password = registerForm.regPassword.value;
    const fileInput = document.getElementById('profileImage')[0];

    const formData = new FormData();
    formData.append('username', username);
    formData.append('password', password);

    if (fileInput) {
        formData.append('profileImage', fileInput);
    }

    const response = await axios.post(`${API_URL}/api/auth/register`, formData, ...);
});
```

