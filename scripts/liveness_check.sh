#!/bin/sh

# Check if the redis-dns-server is running properly
if ! pgrep -f "redis-dns-server" > /dev/null; then
    echo "redis-dns-server is not running."
    exit 1
fi

# Execute the 'd' resolver to check DNS resolution
if ! /d -r ${SERVER_LOAD_BALANCER_IP} -d ${DOMAIN}; then
    echo "DNS resolution check failed."
    exit 1
fi

echo "All checks passed."
exit 0
