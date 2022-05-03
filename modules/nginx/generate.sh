#!/bin/bash

set -e

cf_ip_from() {
  echo "# https://www.cloudflare.com/ips"

  for type in v4 v6; do
    echo
    echo "# IP$type"
    curl -sL "https://www.cloudflare.com/ips-$type/" | sed "s|^|set_real_ip_from |g" | sed "s|\$|;|g"
    echo
  done
  echo
  echo "real_ip_header CF-Connecting-IP;"
  echo "# real_ip_header X-Forwarded-For;"
  echo
}

cf_ips() {

  # for type in v4 v6; do
  #   echo
  #   echo "## IP$type"
  #   curl -sL "https://www.cloudflare.com/ips-$type/" | sed "s|^|# allow |g" | sed "s|\$|;|g"
  #   echo
  # done

  echo "# Generated at $(LC_ALL=C date)"
  # echo
  # echo "# deny all; # deny all remaining ips"
}

(cf_ip_from && cf_ips) > allow-cloudflare.conf
