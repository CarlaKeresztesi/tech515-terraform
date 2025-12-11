#!/bin/bash

echo "User data starting..."

cd repo/app

#export DB_HOST=mongodb://10.0.3.101/posts
export DB_HOST="mongodb://${db_private_ip}:27017/posts"

pm2 start app.js

echo "User data ran..."