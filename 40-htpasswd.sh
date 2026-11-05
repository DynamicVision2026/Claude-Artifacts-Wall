#!/bin/sh
set -e
: "${AUTH_USER:?AUTH_USER is not set}"
: "${AUTH_PASS:?AUTH_PASS is not set}"
htpasswd -bcB /etc/nginx/.htpasswd "$AUTH_USER" "$AUTH_PASS" >/dev/null
