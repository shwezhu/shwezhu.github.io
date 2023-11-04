---
title: HTTP 2.0 Binary Framing
date: 2023-11-04 00:45:30
categories:
 - http
tags:
 - http
typora-root-url: ../../../static
---

## 1. Streams, messages, and frames

At the core of all performance enhancements of HTTP/2 is the new binary framing layer, which dictates how the HTTP messages are encapsulated and transferred between the client and server.

The introduction of the new binary framing mechanism changes how the data is exchanged between the client and server. To describe this process, let’s familiarize ourselves with the HTTP/2 terminology:

- *Stream*: A bidirectional flow of bytes within an established connection, which may carry one or more messages.
- *Message*: A complete sequence of frames that map to a logical request or response message.
- *Frame*: The smallest unit of communication in HTTP/2, each containing a frame header, which at a minimum identifies the stream to which the frame belongs.

The relation of these terms can be summarized as follows:

- All communication is performed over a single TCP connection that can carry any number of bidirectional streams.
- Each stream has a unique identifier and optional priority information that is used to carry bidirectional messages.
- Each message is a logical HTTP message, such as a request, or response, which consists of one or more frames.
- The frame is the smallest unit of communication that carries a specific type of data—e.g., HTTP headers, message payload, and so on. Frames from different streams may be interleaved and then reassembled via the embedded stream identifier in the header of each frame.

<img src="/004-http-v2-binary-frame/cc.png" alt="cc" style="zoom:33%;" />

In short, HTTP/2 breaks down the HTTP protocol communication into an exchange of binary-encoded frames, which are then mapped to messages that belong to a particular stream, all of which are **multiplexed** within a single TCP connection. This is the foundation that enables all other features and performance optimizations provided by the HTTP/2 protocol.

## 2. Request and response multiplexing

With HTTP/1.x, if the client wants to make multiple parallel requests to improve performance, then multiple TCP connections must be used (see [Using Multiple TCP Connections](https://web.archive.org/web/20220126192113/https://hpbn.co/http1x/#using-multiple-tcp-connections) ). This behavior is a direct consequence of the HTTP/1.x delivery model, which ensures that only one response can be delivered at a time (response queuing) per connection. Worse, this also results in head-of-line blocking and inefficient use of the underlying TCP connection. I have talked this in [previous post](). 
