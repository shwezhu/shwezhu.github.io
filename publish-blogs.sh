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

export PATH='/Users/David/sdk/go1.20.4/bin/:$PATH'
export PATH='/opt/homebrew/bin/:$PATH'
export PATH='/usr/bin/:$PATH'

cd blogs/
hugo
cd public/
git switch master
git add .
git commit -m "$(date)"
git push origin master

