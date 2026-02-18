---
name: interflex-clock-in
description: 'Clock in to Interflex with Remote Work using Chrome browser automation'
compatibility: opencode
---

## What I do

Automate clocking in to the Interflex time tracking system with Remote Work, using a running Chrome instance via Chrome DevTools MCP.

## When to use me

Use me when the user wants to clock in to Interflex.
Use me when the user wants to start their work day with Remote Work.
Use me when the user says something like "clock in", "start work", "Kommen", "RW Kommen", or "remote work clock in".

## Prerequisites

- A Chrome browser must be running with remote debugging enabled.
- The Chrome DevTools MCP server must be connected.
- The Bitwarden browser extension must be installed and unlocked in Chrome (for auto-filling credentials).

## Instructions

Follow these steps exactly. Use the `chrome-devtools_*` tools for all browser interactions.

### Step 1: Open Interflex

1. Call `chrome-devtools_list_pages` to check if there is already a tab open at `https://interflex.innio.com/`.
2. If a tab exists, select it with `chrome-devtools_select_page` (set `bringToFront: true`).
3. If no tab exists, open a new one with `chrome-devtools_new_page` to `https://interflex.innio.com/`.
4. Take a snapshot with `chrome-devtools_take_snapshot` to see the current page state.

### Step 2: Handle the landing/login page

1. If the page shows "To proceed, please log in as" (the welcome page), click the **"Employee"** link to go to the PIN login page.
2. If the page shows "Personalnummer" and "PIN-Code" fields (the PIN login page):
   - Click on the Personalnummer text field to focus it.
   - Press `Meta+Shift+L` (Cmd+Shift+L) to trigger Bitwarden autofill.
   - Take a snapshot to verify the fields are populated.
   - Click the **"Anmelden"** button to log in.
   - If a dialog appears saying "Anmeldung fehlgeschlagen" (login failed), accept the dialog and inform the user that login failed.
3. If the page shows "Willkommen im WebClient" or menu tabs like "Startseite", "Zeiterfassung", etc., you are already logged in. Proceed to Step 3.

### Step 3: Navigate to Buchungen

1. Take a snapshot to see the current menu state.
2. If the "Zeiterfassung" tab is not expanded, click on the **"Zeiterfassung"** link to expand it.
3. Click on **"Buchungen"** in the submenu to open the bookings page.
4. Take a snapshot to confirm the Buchungen page loaded (you should see "Kommen", "RW Kommen" buttons and the Kurzjournal).

### Step 4: Clock in with Remote Work

1. On the Buchungen page, click the **"RW Kommen"** button (Remote Work clock in).
2. Take a snapshot to verify the booking was registered.
3. If a confirmation dialog appears, accept it.
4. Report the result to the user, including:
   - The time of the booking
   - The current status (anwesend/abwesend)
   - A brief summary of the Kurzjournal entries for today

### Error Handling

- If at any point a dialog appears, handle it with `chrome-devtools_handle_dialog` and report the message to the user.
- If the page is in an unexpected state, take a screenshot with `chrome-devtools_take_screenshot` and describe what you see to the user.
- If Bitwarden autofill does not populate the fields (values remain empty after pressing Cmd+Shift+L), inform the user that Bitwarden may not be unlocked or may not have matching credentials.
