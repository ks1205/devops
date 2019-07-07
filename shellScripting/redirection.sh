#!/bin/bash
#This is another way to comment in uniz os.
echo "Hello ! Big Data @bash" 1>&2
dates 2>&1 // This will display the error
dates 2>/dev/null // This will not display the error
date &> otput.txt 
