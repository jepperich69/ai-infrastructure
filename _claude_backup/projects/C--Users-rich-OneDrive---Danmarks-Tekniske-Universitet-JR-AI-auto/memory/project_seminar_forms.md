---
name: AI seminar Google Forms
description: Danish and English Google Forms surveys created for AI-assisted research seminar, with links and recreation method
type: project
originSessionId: e8ec280c-0779-404e-9253-04be32b154e5
---
Two anonymous Google Forms surveys created 2026-05-08 for an AI-assisted research seminar.

**Danish form**
Title: AI-assisteret forskning: praksis, infrastruktur og fremtidige behov
Respondent link: https://docs.google.com/forms/d/e/1FAIpQLSduhzPQnQv-P5s86Kx-EWAKQ1CjM-3asKno4cmTp_sQKKdE8g/viewform
QR code: `AI_auto\ai_seminar_qr.png`

**English form**
Title: AI-assisted research: practice, infrastructure and future needs
(Link not logged — check Google Drive / script.google.com under jeppe.rich@gmail.com)

**Structure (both forms)**
- Q1: Where do you use AI? (Checkboxes, 7 options, multiple answers)
- Q2: How close is AI to your files? (Multiple choice, 6 options, single answer)
- Q3: Do you have a local copy of research files? (Multiple choice, 5 options, single answer)
- Q4: Do you use GitHub/version control? (Multiple choice, 5 options, single answer)
- Q5: What would be most valuable from an AI assistant? (Checkboxes, 7 options, multiple answers)
- All questions required, no email collected, no login required

**How to recreate (Apps Script method)**
1. script.google.com > New project
2. Paste script with short concatenated strings (avoid line-wrap syntax errors from chat)
3. Omit setRequireLogin() and setShowSummary() — not supported on consumer Gmail
4. Run > authorize > get link from View > Logs

**Export responses**
Google Forms > Responses tab > Sheets icon > Download as .xlsx

**Why:** setRequireLogin(false) and setShowSummary() are not supported on non-Workspace Gmail accounts. Drive MCP cannot create Forms or Apps Script projects directly.

**How to apply:** When user asks about this seminar survey, the forms exist under jeppe.rich@gmail.com. Use the Apps Script method for any new forms.
