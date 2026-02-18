---
name: assigned-work
description: 'Show a summary of assigned jira tickets and tickets where I have been mentioned'
compatibility: opencode
---

## What I do

Show a summary of Jira tickets that I'm assigned or that I have been mentioned recently

## When to use me

Use me when you want to quickly see the work that has been assigned to me
Use me when you want to quickly see the tasks that have been assigned to me
Use me when you want to show when I have been recently mentioned (last 2 weeks)

## Instructions

1. Show all Jira tickets assigned to me that are not Done. Display them in a table with columns: Key, Summary, Status, Priority. Sort by priority (Highest first).
2. Then show any Jira tickets where I have been mentioned in the last 2 weeks. Use a text-based JQL search with my full name (e.g. `text ~ "David Steinberger" AND updated >= -2w ORDER BY updated DESC`) instead of `mentionedIssues()`, as the latter is unreliable and often misses mentions. Exclude tickets already shown in the assigned table. Display these in a separate table with columns: Key, Summary, Status, Updated.
