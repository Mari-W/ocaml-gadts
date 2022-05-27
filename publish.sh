#!/bin/bash
git add .
git commit -m "[ slides ] $1"
sh ./build.sh
git add .
git commit -m "[ publish ] generated files"
git push