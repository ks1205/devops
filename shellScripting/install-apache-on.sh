#!/bin/bash

# This script installs the apache web server on the given host.
# This script assumes the user running it has sudo privs on the remote host.

usage() {
  # Display the usage and exit.
  echo "Usage: ${0} HOST [HOSTN...]" >&2
  exit 1
}

# Make sure the script is not being executed with superuser privileges.
#Comment below if condition as we are going to run this script as root
#if [[ "${UID}" -eq 0 ]]
#then
#  echo 'Do not execute this script as root.' >&2
#  usage
#fi

# If the user doesn't supply at least one argument, give them help.
if [[ "${#}" -lt 1 ]]
then
  usage
fi

# Expect the best, prepare for the worst.
EXIT_STATUS='0'

# Loop through the provided servers.
for SERVER in "${@}"
do
  echo "Starting installation process on: ${SERVER}"

  # Ping the server to make sure it's up.
  ping -c 1 ${SERVER} &> /dev/null

  if [[ "${?}" -ne 0 ]]
  then
    echo "${SERVER} down."
    EXIT_STATUS='1'
    continue
  fi

  # Install the httpd package
  ssh ${SERVER} yum install -y httpd

  # Create an index.html file.
  ssh ${SERVER} 'echo "${HOSTNAME}" | tee /var/www/html/index.html >/dev/null'

  # Start httpd
  ssh ${SERVER} systemctl start httpd

  # Enable httpd
  ssh ${SERVER} systemctl enable httpd

  # Test that the web server is accessible.
  curl http://${SERVER}

  if [[ "${?}" -ne 0 ]]
  then
    echo "Could not access the web server on ${SERVER}." >&2
    EXIT_STATUS='1'
    continue
  fi

  echo "Finished installation process on: ${SERVER}"
done

exit ${EXIT_STATUS}
