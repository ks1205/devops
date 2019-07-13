#!/bin/bash

total=$1
if [ $total = 1 ]; then
  echo "The number is equal to 1"
else
  echo "The number is NOT equal to 1"
fi

if test $total -eq 1
then
  echo "The number is equal to 1"
else
  echo "The number is NOT equal to 1"
fi
