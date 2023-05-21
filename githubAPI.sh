#!/bin/bash
##########################################################################################
# Author: debenick17                                                                     #
# version: 1                                                                             #
#                                                                                        #
#                                                                                        #
#                                                                                        #
# This scripts helps communicate with the GitHub API to retrieve information             #
# Note: You need to provide your github token and rest API to the scripts as parameters  #
#                                                                                        #
##########################################################################################


if [ ${#@} -lt 2 ]; then
  echo "usage: $0 [your github token] [REST expression]" # $0 is the first the script name
  exit 1;
fi

GITHUB_TOKEN=$1
GITHUB_API_REST=$2

GITHUB_API_HEADER_ACCEPT="Accept: application/vnd.github.v3+json"

temp=`basename $0`
TEMPFILE=(mktemp /tmp/${temp}.XXXXXX) || exit 1;


function rest_call {
  curl -s $1 -H "${GITHUB_API_HEADER_ACCEPT}" -H "Authorization: token $GITHUB_TOKEN" >> $TMPFILE
}

# For a single page result(no pagination), have no Link: section, the grep result is empty
last_page=`curl -s -I "https://api.github.com${GITHUB_API_REST}" -H "${GITHUB_API_HEADER_ACCEPT}" -H "Authorization: token $GITHUB_TOKEN" | grep '^Link:' | sed -e 's/^Link:.*page=//g' -e 's/>.*$//g'`

# Check if pagination exists or not
if [ -z "$last_page" ]; then
  # # no - this result has only one page
  rest_call "https://api.github.com${GITHUB_API_REST}"
else
  # yes - this result is on multiple pages
  for p in `seq 1 $last_page`; do
    rest_call "https://api.github.com${GITHUB_API_REST}?page=$p"
  done
fi

cat $TEMPFILE