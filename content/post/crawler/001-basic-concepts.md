---
title: Basic Concepts
date: 2023-11-26 19:29:35
categories:
 - crawler
tags:
 - crawler
---

## 1. Web crawler

A Web crawler, sometimes called a spider or spiderbot and often shortened to crawler, is an Internet bot that systematically browses the World Wide Web and that is typically operated by search engines for the purpose of Web indexing (web spidering). [Web crawler](https://en.wikipedia.org/wiki/Web_crawler)

## 2. Headless browser

A headless browser is a web browser that operates without a graphical user interface (GUI). It runs in the background and interacts with web pages programmatically, just like a regular browser, but without displaying the web page to the user. Headless browsers are commonly used in web crawling and scraping applications.

Learn more: [Web Scraping Without Getting Blocked | ScrapeOps](https://scrapeops.io/web-scraping-playbook/web-scraping-without-getting-blocked/)

## 3. Playwright library

Playwright is an open-source automation library for browser testing and web scraping developed by Microsoft and launched on 31 January 2020, which has since become popular among programmers and web developers. Playwright provides the ability to automate browser tasks in Chromium, Firefox and WebKit with a single API. 

> *Playwright* is a framework for Web Testing and Automation. It allows testing Chromium, Firefox and WebKit with a single API.  [microsoft/playwright](https://github.com/microsoft/playwright)

## 4. JavaScript rendering

JavaScript rendering is the process of executing JavaScript on a page to make changes in the page's structure or content. It's also called client-side rendering, the opposite of server-side rendering. Some modern websites render on the client, some on the server and many cutting edge websites render some things on the server and other things on the client.

Javascript uses the **document object model (DOM)** to manipulate the DOM elements. **Rendering** refers to showing the output in the browser. 

Learn more: 

- [What is JavaScript rendering?](https://www.educative.io/answers/what-is-javascript-rendering)

- [JavaScript rendering | Crawlee](https://crawlee.dev/docs/guides/javascript-rendering)

## 5. Anti-Scraping

It refers to all techniques, tools, and approaches to protect online data against scraping. In other words, anti-scraping makes it more difficult to automatically extract data from a web page. Specifically, **it's about identifying and blocking requests from bots or malicious users**.

Learn more: [7 Anti-Scraping Techniques You Need to Know - ZenRows](https://www.zenrows.com/blog/anti-scraping#user-behavior-analysis)

## 6. Is there an easy way to tell if a website will allow scrapers or not?

To find out if the website allows scraping then check out:

- **Robots.txt file:** This will say which pages can you access with a scraper.
- **Terms & Conditions:** Their T&Cs will normally say if they permit scraping, programmatic access, etc.
  - Check the link below, at the end there is: *You will not access the Site through automated or non-human means, such as with bots, scripts or otherwise;....*
  - When you login you usually see: I have read and understood the [Privacy Policy and the Terms of Use](https://ais.usvisa-info.com/en-ca/niv/information/privacy_policy). 

- **Presence of Anti-Bot Protection:** If you are getting ban pages from Cloudflare, Distill Network, Imperva, DataDome, etc. then it is highly likely that the website doesn't want you to scrape them. 

If you are getting blocked but still want to scrape the website then you can do the following:

- **User-Agents & Headers:** You need to use fake user-agents when scraping as most HTTP clients clearly identify themselves by default, giving you away as a scraper. Better yet you should use full fake browser headers that match what a real browser should send to a website. More about [how to optimize and generate browser headers here](https://scrapeops.io/web-scraping-playbook/web-scraping-guide-header-user-agents/).
- **Rotating Proxies:** You should send your requests via a rotating proxy pool that will make it harder for the website to detect you as a scraper. Residential & Mobile proxies are better than datacenter proxies but are a lot more expensive. [You can compare proxy provider plans here](https://scrapeops.io/proxy-providers/comparison/).
- **Fortified Headless Browser:** Depending on the anti-bot protection the website is using you make need to use a fortified headless browser that can solve its JS challenges without giving its identity away. Your options include the [Puppeteer stealth plugin](https://github.com/berstend/puppeteer-extra/tree/master/packages/puppeteer-extra-plugin-stealth) and [Selenium undetected-chromedriver](https://github.com/ultrafunkamsterdam/undetected-chromedriver).

Learn more about it here [Guide to Web Scraping Without Getting Blocked](https://scrapeops.io/web-scraping-playbook/web-scraping-without-getting-blocked/).

Learn more: https://www.reddit.com/r/webscraping/comments/xvqd6r/comment/ir4m0xx/?utm_source=share&utm_medium=web2x&context=3
