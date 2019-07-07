#!/bin/bash
directoryName="$1"
if test -d $directoryName
then
  echo "$directoryName exists!!!"
else
  echo "$directoryName does not exists!!!"
fi
