---
name: review-pull-request
description: Review a GitHub pull request by checking out the branch and performing a code review
compatibility: opencode
---

## What I do

Ask the user for a PR URL, check out the branch locally, then perform a full code review directly.

## When to use me

Use me when the user wants to review a pull request.
Use me when the user says "review PR", "review pull request", or "code review".

## Instructions

### Step 1: Ask for the PR URL

If the user has not already provided one, ask:

> "Please provide the GitHub pull request URL."

### Step 2: Verify the current repo matches the PR

Parse the owner, repo, and PR number from the URL.

Run `git remote get-url origin` and check that the remote URL contains `<owner>/<repo>`.

If it does not match, stop and tell the user:

> "This PR belongs to `<owner>/<repo>` but OpenCode is running in a different repository. Please run OpenCode from the correct repo."

### Step 3: Check out the PR branch and review the code

Fetch the PR head ref and check it out locally:

```bash
git fetch origin pull/<PR number>/head:<branch-name>
git checkout <branch-name>
```

Use the branch name from the PR URL or derive a sensible local name like `pr-<PR number>`.

Then perform a thorough code review of the changes introduced by this branch. 
Do not commit any changes and do not push anything to the remote(code, comments, or otherwise) without explicit instructions from the user.
