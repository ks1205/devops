#!/bin/bash

# A list of servers, one per line.
SERVER_LIST='/vagrant/servers'
USER_NAME='ec2-user'
# SSH timeout for 2 mins Options for the ssh command.

SSH_TIMEOUT_OPTIONS='-o ConnectTimeout=2'
PRIVATE_KEY_FILE_OPTION='-i /opt/devops/AWS-demo-RHEL7.5.pem'

#Usage funtion wil give the breif about how to execute the script

usage() {
 # Display the usage and exit.
 echo "Usage: ${0} [-nsv] [-f FILE] COMMAND" >&2
 echo 'Executes COMMAND as a single command on every server.' >&2
 echo " -f FILE, Use FILE for the list of servers. Default: ${SERVER_LIST}." >&2
 echo ' -n Dry run mode. Display the COMMAND that would have been executed and exit.' >&2
 echo ' -s Execute the COMMAND using sudo on the remote server.Use when using Private Key Authentication' >&2
 echo ' -v Verbose mode. Displays the server name before executing COMMAND.' >&2
 echo ' -p With Private key. SSH connection will done with .pem file. Default : /opt/devops/*.pem' >&2
 exit 1
}
#Make sure the script is not being executed with superuser privileges.
#We have configured our SSH with root so we don't need belo if check condition

#if [[ "${UID}" -eq 0 ]]
#then
#	echo 'Do not execute this script as root. Use the -s option instead.' >&2
#	usage
#fi

#Parse the options.
while getopts f:nsvp OPTION
do
	case ${OPTION} in
 	f) SERVER_LIST="${OPTARG}" ;;
 	n) DRY_RUN='true' ;;
 	s) SUDO='sudo' ;;
 	v) VERBOSE='true' ;;
	p) PRIVATE_KEY_FLAG='true' ;;
 	?) usage ;;
	esac
done
# Remove the options while leaving the remaining arguments.
shift "$(( OPTIND - 1 ))"
# If the user doesn't supply at least one argument, give them help.

if [[ "${#}" -lt 1 ]]
then
	usage
fi

# Anything that remains on the command line is to be treated as a single command.
COMMAND="${@}"
# Make sure the SERVER_LIST file exists.
if [[ ! -e "${SERVER_LIST}" ]]
then
	echo "Cannot open server list file ${SERVER_LIST}." >&2
 exit 1
fi
# Expect the best, prepare for the worst.
EXIT_STATUS='0'
# Loop through the SERVER_LIST
for SERVER in $(cat ${SERVER_LIST})
do
	if [[ "${VERBOSE}" = 'true' ]]
 	then
 		echo "${SERVER}"
 	fi
	PRIVATE_SSH_COMMAND="ssh ${SSH_TIMEOUT_OPTIONS} ${PRIVATE_KEY_FILE_OPTION} ${USER_NAME}@${SERVER} ${SUDO} ${COMMAND}"
	if [[ "${PRIVATE_KEY_FLAG}" = "true" && "${SUDO}" = "sudo" ]]
	then
		#If it's a dry run, don't execute anything, just echo it.
		if [[ "${DRY_RUN}" = "true" ]]
		then
			echo "DRY RUN: ${PRIVATE_SSH_COMMAND}"
		else
			${PRIVATE_SSH_COMMAND}
			SSH_EXIT_STATUS="${?}"
		fi
	else
		echo "Please give -s as private key auth is using ec2-user"
		usage
	fi

#Capture any non-zero exit status from the SSH_COMMAND and report to the user.
 	if [[ "${SSH_EXIT_STATUS}" -ne 0 ]]
 	then
 		EXIT_STATUS=${SSH_EXIT_STATUS}
 		echo "Execution on ${SERVER} failed." >&2
 	fi
 	
done
exit ${EXIT_STATUS}
