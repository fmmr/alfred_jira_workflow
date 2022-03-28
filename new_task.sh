#!/bin/bash

# small script to create a task (or other issue type in jira
# integrates well with alfred etc.
#
# the following env-variables must be set for the script to run successfully:
# JIRA_URL, JIRA_USER, JIRA_PW, JIRA_PROJECT, JIRA_ISSUE_TYPE
#
#
# to delete a task
# username=fredrik.rodland@finn.no
# password=XXXX
# task=SEARCH-9971
# curl -X DELETE -u "$username:$password" https://finn-jira.atlassian.net/rest/api/3/issue/$task

JQ="${JQ:-/opt/homebrew/bin/jq}"
username=$JIRA_USER
password=$JIRA_PW
project=$JIRA_PROJECT
issue_type="${JIRA_ISSUE_TYPE:-Task}"

post_url="https://$JIRA_URL/rest/api/latest/issue"

description="SSIA"
label="search"

summary=$(echo -e "$*")
do_post=1

function debug() {
  echo >&2 "$*"
}

# shellcheck disable=SC2016
data=$(
  $JQ -n -c --arg p "$project" --arg s "$summary" --arg it "$issue_type" --arg d "$description" --arg l "$label" \
    '{fields:{project: {key: $p}, summary: $s, description: $d, labels: [$l], issuetype: {name: $it}}}'
)

debug "summary: " "$summary"
debug "post_url: " "$post_url"
debug "data: " "$data"

if [ $do_post == 1 ]; then
  result=$(curl -q -s $post_url \
    -u "$username:$password" \
    -H 'Content-Type: application/json' \
    -d "$data")

  debug "result" "$result"
  issue_number=$(echo "$result" | $JQ -r '.key')

  result_url="https://$JIRA_URL/browse/$issue_number"

  echo "$issue_number"
  echo "summary: $summary"
  open "$result_url"
fi
