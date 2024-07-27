---
title: Asp .Net Core Basics
date: 2024-07-26 19:42:36
categories:
 - c sharp
---

## 1. Model Binding

### 1.1. Complex Type

A complex type must have a **public default constructor** and **public writable properties** to bind. When model binding occurs, the class is instantiated using the public default constructor.

> **Note:**  When you use the `[ApiController]` attribute, ASP.NET Core automatically handles model validation for you. If the model state is invalid, it returns a 400 Bad Request response with validation errors before your action method is even executed. Therefore, `if (!ModelState.IsValid){...}` is not needed in this case. 

Now we can talk about the model binding's behaviours, let's talk when error happens first. We know that the complex type must have `public default constructor` and `public writable properties`, otherwise binding process fails. 

```c#
[ApiController]
[Route("/")]
public class WeatherForecastController : ControllerBase
{
    [HttpPost(Name = "CreateCat")]
    public IActionResult CreateCat(Cat cat)
    {
        Console.WriteLine($"Cat Info: {cat.Name}, Age: {cat.Age}");
        return Ok(cat);
    }
}

public class Cat
{
    public string Name;
    public int Age;
}
```

### 1.1.1. No `public writable properties`

We make a post request and get a empty json response:

```bash
❯ curl -X POST http://localhost:5079/ \
  -H "Content-Type: application/json" \
  -d '{"Name":"Jelly", "Age":2}'
{}
```

Then the web server's console output:

```c#
Cat Info: , Age: 0
```

Why? Because class `Cat` has two fields no **public writable properties**. So if we change our code like this:

```c#
public class Cat
{
    public string Name { get; set; }
    public int Age { get; set; }
}
```

Then we get the response as we expected:

```bash
❯ curl -X POST http://localhost:5079/ \
  -H "Content-Type: application/json" \
  -d '{"Name":"Jelly", "Age":2}'
{"name":"Jelly","age":2}
```

### 1.1.2. No `public default constructor`

```c#
public class Cat
{
    public Cat(string name, int age)
    {
        Name = name;
        Age = age;
    }
    
    public string Name { get; }
    public int Age { get;}
}
```

This no public default constructor `public Cat() {}`,  but it still works, it seems related to that Since 3.0 .NET Core [uses the newer System.Text.Json serializer by default](https://learn.microsoft.com/en-us/aspnet/core/migration/22-to-30?view=aspnetcore-3.1&tabs=visual-studio#newtonsoftjson-jsonnet-support). Learn more: https://stackoverflow.com/a/60406568/16317008

Besides, with this code , we still get correct response:

```bash
~
❯ curl -X POST http://localhost:5079/ \
  -H "Content-Type: application/json" \
  -d '{"Name":"Jelly"}'
{"name":"Jelly","age":0}
```

But if we don't provide `name`:

```c#
❯ curl -X POST http://localhost:5079/ \
  -H "Content-Type: application/json" \
  -d '{"Age":2}'
{"type":"https://tools.ietf.org/html/rfc9110#section-15.5.1","title":"One or more validation errors occurred.","status":400,"errors":{"Name":["The Name field is required."]},"traceId":"00-878373b66e99961173616bf9a380c732-029477b4ec5e8f8b-00"}
```

### 1.1.3. Other Behaviors

Now our code is 

```c#
public class Cat
{
    public string Name { get; }
    public int Age { get;}
}
```