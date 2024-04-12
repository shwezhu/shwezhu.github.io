---
title: Go File Server Cannot Handle Large Files
date: 2024-04-12 10:42:22
categories:
 - bugs
tags:
 - bugs
 - golang
---

## 1. Problem description

Considering the limitation of the RAM on my VPS, when user attempting to upload a large file, I want to handle the file in chunks, so that I can read the file in small pieces and write them to the disk. And this process is called **streaming**. 

The code snippet is like this:

```go
func (s *server) handleUpload(w http.ResponseWriter, r *http.Request, currentDir string) (errs []uploadError) {
	// limit the size of incoming request bodies.
	r.Body = &LimitedReader{r: r.Body, n: int64(s.maxFileSize * 1024 * 1024)}

	reader, err := r.MultipartReader()
	if err != nil {...}

	for {
		// reader.NextPart() will close the previous part automatically.
		part, err := reader.NextPart()
		if err != nil {...}

		// not a file, move to the next part.
		if part.FileName() == "" {
			continue
		}

		filename := getAvailableName(currentDir, part.FileName())
		dstPath := filepath.Join(currentDir, filename)
		dst, err := os.Create(dstPath)
		if err != nil {...}

		// io.Copy() will stream the file to dst, multipart.Part is an io.Reader.
		_, err = io.Copy(dst, part)

		if err != nil {...}
		if err = dst.Close(); err != nil { ... }
	}

	return
}
```

But when I try to upload a file of 1.6GB, it takes a long time to finish (about 2 minutes), I thought it may caused by the CPU speed of my VPS or the I/O speed of the disk or the network speed. 

But at the browser side, the uploading progress bar is always at 100%, and the browser is waiting for the response from the server, which indicates that the uploading process is finished, but the server is still processing the file.

I use `htop` to check the CPU usage of my VPS, it's around 20% when uploading the file, which indicates that the CPU is not the bottleneck.

Then I use `dd` to test the I/O speed of my disk, it's around 488MB/s, which is not bad.

Then why the server is still processing the file so long? 

Besides, when my server is processing the file, if I refresh the page, the RAM and cpu usage of my VPS will increase to 100%, and the server will get killed by the OS. This is super weird.


## 2. Solution for high CPU usage

Check the code snippet I provided before, there is: 

```go
for {
    // reader.NextPart() will close the previous part automatically.
    part, err := reader.NextPart()
    if err != nil {
        if err == io.EOF { // finish reading all parts, exit the loop
            break
        }

        errs = append(errs, uploadError{Message: fmt.Sprintf("reader.NextPart(): %v", err)})

        continue
    }
}
```

What if the error is not `io.EOF`, but other errors? Then there will be a infinite loop, this is the reason why the CPU usage is high. What I do is to limit the size of the error message:

```go
if err != nil {
    if err == io.EOF { // finish reading all parts, exit the loop
        break
    }

    errs = append(errs, uploadError{Message: fmt.Sprintf("reader.NextPart(): %v", err)})

    // too many errors, stop uploading, you must limit the number of errors in case of infinite loop.
    if len(errs) >= 10 {
        errs = append(errs, uploadError{Message: "Maximum error limit reached"})
        return
    }

    continue
}
```

## 3. Solution for slow uploading speed

I ask this question in Go community that I joined, and I got a suggestion: 

Form Upload(`multipart/form-data`) is not good for large files, when uploading a large file, we usually use Binary Stream Uploads(`application/octet-stream`) instead, use `r.Body` directly to read the file content, and write the content to the disk this is real streaming. 

Actually, with `multipart/form-data`, the file content is read by block, not the real streaming, you can check the code I provided before: `part, err := reader.NextPart()`. 

So use `PUT` with `application/octet-stream` instead of `multipart/form-data` to upload large files. 

