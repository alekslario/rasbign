#!/bin/bash

API_KEY=$(doppler --project rasbign --config dev_user secrets get API_KEY --plain)
res=$(curl -H "x-api-key:$API_KEY" $1/rasbign?prompt=lion)

#remove line breaks
res=$(echo "$res" | tr -d '\n')

IFS="😀"
read -ra array <<< $res
#error
echo "${array[0]}"
if ((${#array[@]} > 1)); then
  #error
  echo "${array[1]}" > error.html
  base64 -d <<< "${array[2]}" > error.jpg
  echo "${array[3]}" > dump.txt
fi