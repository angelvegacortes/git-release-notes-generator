#!/bin/bash

# setup variables
DUMMY_GIT_LOGS="./logs.txt"
RELEASE_NOTES_TARGET_FILE="./release-notes.md"
JIRA_TICKET_PATTERN="ABC[A-Z]\+-[0-9]\+"
JIRA_TICKET_BASE_URL="https:\/\/jira.dev\/view\/issue"
JIRA_JQL_DELIMITER=","
JIRA_JQL_BASE_URL="https://jira.dev/search?jql"

# add git logs to release notes
# git log --pretty='format:%s (%h by %an)' > $RELEASE_NOTES_TARGET_FILE
# NOTE: simulate the line above by using dummy git logs
cp $DUMMY_GIT_LOGS $RELEASE_NOTES_TARGET_FILE

# find and store all jira tickets
jira_tickets=$( grep -o "$JIRA_TICKET_PATTERN" "$RELEASE_NOTES_TARGET_FILE" | sort | uniq )

# add hyperlinks to all jira tickets
for jira_ticket in ${jira_tickets[@]}; do
    jira_ticket_url="[$jira_ticket]($JIRA_TICKET_BASE_URL\/$jira_ticket)"
    sed -i '' "s/$jira_ticket/$jira_ticket_url/g" "$RELEASE_NOTES_TARGET_FILE"
done

# add link to all jira tickets
concatenated_jira_tickets=$(printf "%s$JIRA_JQL_DELIMITER" ${jira_tickets[@]})
# remove trailing delimiter
concatenated_jira_tickets=${concatenated_jira_tickets%"$JIRA_JQL_DELIMITER"}
jira_jql_url="$JIRA_JQL_BASE_URL=key%20in%20($concatenated_jira_tickets)"
echo "" >> "$RELEASE_NOTES_TARGET_FILE"
echo "[View all tickets in JIRA]($jira_jql_url)" >> "$RELEASE_NOTES_TARGET_FILE"

# done
echo "Completed release notes [$RELEASE_NOTES_TARGET_FILE]"
