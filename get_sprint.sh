rapidboard=15

if [ "z" != "z$1" ]; then
  rapidboard=$1
fi


curl -s "https://jira.finn.no/rest/greenhopper/1.0/sprintquery/$rapidboard" | sed -e 's/.*id":\([0-9]*\)[^{]*"state":"ACTIVE".*/\1/'