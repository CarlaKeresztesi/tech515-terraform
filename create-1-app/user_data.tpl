#!/bin/bash

# originally .sh (bash script) file -> changed to .tpl (template file)

echo "User data starting..."

cd repo/app

# export DB_HOST=mongodb://172.31.62.136/posts
export DB_HOST="mongodb://${db_private_ip}:27017/posts"

pm2 start app.js

echo "User data ran..."