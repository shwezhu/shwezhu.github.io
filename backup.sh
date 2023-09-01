#!/bin/bash
git switch backup
git add .
git commit -m "$(date)"
git push origin backup