#!/bin/bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Publish Blogs
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author David
# @raycast.authorURL https://raycast.com/shwezhu

hugo
cd public/
git add .
git commit -m "$(date)"
git push origin master

