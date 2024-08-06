---
title: Form Data in JS
date: 2024-08-04 23:02:10
categories:
 - front-end
tags:
 - front-end
---

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
      // 1. Get data by Id
      const username = document.getElementById('regUsername').value;
      const password = document.getElementById('regPassword').value;
      const formData = {...}
                        
      // 2. Use form directly
      const formData = new FormData(registerForm);
      ...
</script>
```

The first method is used for simple `application/json` data transfer. 

Use `FormData()` when you want sends data as `multipart/form-data`. 

`FormData()` creates a FormData object. It uses the `name` attribute of each form element as the key in the key-value pairs it creates. For `FormData(registerForm)`, if an input element in the `registerForm` is empty, the behavior is as follows:

1. The empty input will still be included in the FormData object.
2. The value for that input will be an empty string, or an empty File object for different input types. 

There are a couple of things to keep in mind:

1. Form element names: Make sure your form elements have the correct 'name' attributes, as FormData uses these as keys.
2. Additional data: If you need to add data that's not in the form, you can still append to the FormData object after creating it:

```js
const formData = new FormData(registerForm);
formData.append('extraData', 'someValue');
```

