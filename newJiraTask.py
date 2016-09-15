import sys
import webbrowser as wb
import os

import simplejson as json
 
from restkit import Resource, BasicAuth, request

username = os.environ.get('JIRA_USER')
server_url = os.environ.get('JIRA_URL')
password = os.environ.get('JIRA_PW')
project = os.environ.get('JIRA_PROJECT')
issuetype = os.environ.get('JIRA_ISSUE_TYPE')
sprint = os.getenv('JIRA_SPRINT', "")

def createTask(server_base_url, user, password, project, sprint, issuetype, task_summary):
    auth = BasicAuth(user, password)
 
    resource_name = "issue"
    complete_url = "%s/rest/api/latest/%s/" % (server_base_url, resource_name)
    resource = Resource(complete_url, filters=[auth])
    nullish = "null"
    try:
        data = {
            "fields": {
                "project": {
                    "key": project
                },
                "summary": task_summary,
                "description": "SSIA",
                "customfield_10271": sprint,
                "labels": ["search"],
                "issuetype": {
                    "name": issuetype
                }
                #,
                #"assignee": {
                #    "name": "frerodla",
                #}
            }
        }
        response = resource.post(headers = {'Content-Type' : 'application/json'}, payload=json.dumps(data))
    except Exception, ex:
        print "EXCEPTION: %s " % ex.msg
        return None

    if response.status_int / 100 != 2:
        print "ERROR: status %s" % response.status_int
        return None
 
    issue = json.loads(response.body_string())
    return issue
 
if __name__ == '__main__':
    if (len(sys.argv) != 2):
        print "Usage: %s project <sprint?> issuetype task_summary" % sys.argv[0]
        sys.exit(1);

    task_summary = sys.argv[1].strip()

    issue = createTask(server_url, username, password, project, sprint, issuetype, task_summary)
    
    issue_code = issue["key"]
    issue_url = "%s/browse/%s" % (server_url, issue_code)
    os.environ['JIRA_ISSUE'] = issue_code
    
    if (issue != None):
        print issue_code
        print "summary: %s" % task_summary
        wb.open(issue_url)
    else:
        sys.exit(2)