#!/bin/bash
echo "What is your preffered language? (0 - EXIT)"
echo "1) bash"
echo "2) perl"
echo "3) Python"
echo "0) None of the above !"
read case
case $case in 
	1) echo "You have selected bash!"
	;;
	2) echo "You have selected perl!"
	;;
	3) echo "You have selected Python!"
	;;
        0) echo "Oops! Your choice is not available!"	
	exit
esac

