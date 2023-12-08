#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title backup_blog
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author shwezhu
# @raycast.authorURL https://raycast.com/shwezhu

git switch hugo-blog
git add .
git commit -m "$(date)"
git push origin hugo-blog

hugo
cd public/
git switch master
git add .
git commit -m "$(date)"
git push origin master