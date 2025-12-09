#!/bin/bash

echo "User data starting..."

cd repo/app

pm2 start app.js

echo "User data ran..."