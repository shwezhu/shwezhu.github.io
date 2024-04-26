#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Backup Blogs
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author David
# @raycast.authorURL https://raycast.com/shwezhu

git switch hugo-blog
git add .
git commit -m "$(date)"
git push origin hugo-blog


