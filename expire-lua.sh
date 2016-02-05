#!/bin/bash

if [ $# -ne 4 ]
then
  echo "Expire keys from Redis matching a pattern using SCAN & EXPIRE"
  echo "Usage: $0 <host> <port> <password> <pattern>"
  exit 1
fi

cursor=-1
keys=""
total_count=0

while [[ $cursor -ne 0 ]]; do
  if [[ $cursor -eq -1 ]]
  then
    cursor=0
  fi

  reply=$(redis-cli -h $1 -p $2 -a $3 SCAN $cursor MATCH $4 COUNT 500)
  cursor=$(expr "$reply" : '\([0-9]*[0-9 ]\)')
  if [[ $? -eq 3 ]]; then
    echo "Error: $reply"
  fi

# echo "Cursor: $cursor"

  keys=$(echo $reply | awk '{for (i=2; i<=NF; i++) print $i}')
  [ -z "$keys" ] && continue

  keya=( $keys )

  count=$(echo ${#keya[@]})
  total_count=$((total_count + count))
  echo "Checking $count keys (Total: $total_count)"
  key_count=$(redis-cli -h $1 -p $2 -a $3 EVAL "$(cat print-to-expire.lua)" $count $keys)

  if [[ $key_count > 0 ]]; then
    echo "Would expire $key_count keys"
  fi
  
  sleep 1
done

echo "Total keys $total_count"
