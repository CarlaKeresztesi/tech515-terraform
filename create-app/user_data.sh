#!/bin/bash

echo "User data starting..."

cd repo/app

export DB_HOST=mongodb://172.31.62.136/posts

pm2 start app.js

echo "User data ran..."