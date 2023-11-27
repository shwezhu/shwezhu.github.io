---
title: Clawlee Library - Get Started 
date: 2023-11-26 21:29:35
categories:
 - crawler
tags:
 - crawler
---

## 1. `enqueueLinks`, `maxRequestsPerCrawl`, `headless`

- `enqueueLinks`: is used to add the links exist in current page to a queue for crawler to process. 
- `maxRequestsPerCrawl`: control the maximum of requests the crawler can make, you should **always** set it. 
- `headless`: set it false, you will see all the actions on browser, browser will click link itself (controlled by your js program). 

```js
import { PlaywrightCrawler, Dataset } from 'crawlee';
 
// PlaywrightCrawler crawls the web using a headless
// browser controlled by the Playwright library.
const crawler = new PlaywrightCrawler({
    // Use the requestHandler to process each of the crawled pages.
    async requestHandler({ request, page, enqueueLinks, log }) {
        const title = await page.title();
        log.info(`Title of ${request.loadedUrl} is '${title}'`);

        // Extract links from the current page
        // and add them to the crawling queue.
        await enqueueLinks();
    },
    // Uncomment this option to see the browser window.
    // headless: false,

    // This value should always be set in order to prevent infinite loops in misconfigured crawlers.
    maxRequestsPerCrawl: 3,
});

// Add first URL to the queue and start the crawl.
await crawler.run(['https://github.com/apify/crawlee']);
```

Output:

```js
❯ npm start

> my-crawler@0.0.1 start
> node src/main.js

INFO  PlaywrightCrawler: Starting the crawler.
INFO  PlaywrightCrawler: Title of https://github.com/apify/crawlee is 'GitHub - apify/crawlee'
INFO  PlaywrightCrawler: Title of https://github.com/ is 'GitHub: Let’s build from here · GitHub'
INFO  PlaywrightCrawler: Title of https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E&source=header-repo is 'Join GitHub · GitHub'
INFO  PlaywrightCrawler: Crawler reached the maxRequestsPerCrawl limit of 3 requests and will shut down soon. 
...
INFO  PlaywrightCrawler: Finished! Total 4 requests: 4 succeeded, 0 failed. {"terminal":true}
```

As you can see, the output above: *Crawler reached the maxRequestsPerCrawl limit of 3 requests...*

You probably notice that we just specified only one url, why the crawler makes 3 requests? 

It makes three requests because we set `maxRequestsPerCrawl: 3` above. Besides, because of we added parameter `enqueueLinks`, which pushes the all links (exist in the current page) into the request queue of the crawler, and this is a loop, so this is why we need set `maxRequestsPerCrawl: 3`. 

## 2. 
