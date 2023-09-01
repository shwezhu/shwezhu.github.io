#!/bin/bash
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