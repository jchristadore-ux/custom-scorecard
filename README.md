# PlayPal Custom Scorecard

This project is a single-page golf scorecard app (`index.html`) with:
- live scoring,
- print-ready scorecard output,
- email + GHIN submission workflow,
- and round-code based realtime sync support.

## 1) Auto emails with **PDF attachment identical to Print view**

### What is implemented
- The Save Round flow now generates a PDF from the **same `#scorecard-preview` used by Print**.
- The PDF is attached through EmailJS template variables:
  - `scorecard_pdf_base64`
  - `scorecard_pdf_name`
- If EmailJS is not configured, the app still falls back to `mailto:` text body.

### Setup steps
1. Create an EmailJS account: https://www.emailjs.com
2. Create:
   - one **Email Service**
   - one **Email Template**
3. In `index.html`, set `EmailService` config:
   - `EMAILJS_SERVICE_ID`
   - `EMAILJS_TEMPLATE_ID`
   - `EMAILJS_PUBLIC_KEY`
4. In your EmailJS template, map these variables:
   - `to_email`, `to_name`, `subject`, `scorecard_html`, `course_name`, `round_date`
   - `scorecard_pdf_base64`, `scorecard_pdf_name`
5. Configure attachment in template using the base64/pdf vars (EmailJS supports attachments via template params).

### Notes
- PDF generation uses `html2canvas` + `jsPDF` from CDN.
- Because it renders from the Print DOM, it stays visually consistent with the print layout.

---

## 2) GHIN integration with **per-player authentication**

### What is implemented
- Each player now has:
  - GHIN number,
  - GHIN login email,
  - GHIN password.
- GHIN login token is obtained per player and cached by golfer number for score posting.
- Save Round modal marks players as “Need GHIN login” if GHIN auth fields are missing.

### Setup steps
1. For each player, enter:
   - GHIN #
   - GHIN login email
   - GHIN password
2. On Save Round, app calls:
   - `POST /golfers/login.json`
   - `POST /golfers/{ghin}/scores.json`
3. Verify your GHIN account/API access permissions for the score-posting endpoint.

### Security recommendation
- This static app stores credentials in-memory/client-side during runtime.
- For production, move GHIN auth to a backend proxy:
  - device sends score payload only,
  - server performs GHIN auth + posting,
  - server stores secrets securely.

---

## 3) Unique round code + realtime multi-device tracking

### What is implemented
- New **Live Round Sync** section:
  - Generate Code
  - Join Code
  - Leave Sync
- Realtime sync abstraction is implemented with Supabase Realtime channels.
- Code is used as channel suffix: `round-<CODE>`.

### Setup steps
1. Create a Supabase project.
2. In `RealtimeService` in `index.html`, set:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
3. Ensure Realtime is enabled in the Supabase project.
4. On one device: click **Generate Code**.
5. On other devices: enter code and click **Join Code**.
6. Scoring/setup mutations broadcast snapshots in near realtime.

### Behavior
- If Supabase keys are blank, app shows local-only status (no cross-device sync).
- Once configured, devices connected to the same code receive snapshot updates.

---

## Local run
Because this is static HTML, you can open directly in browser or serve with:

```bash
python -m http.server 8080
```

Then open `http://localhost:8080`.
