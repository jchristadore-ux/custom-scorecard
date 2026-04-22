# PlayPal Custom Scorecard

This project is a single-page golf scorecard app (`index.html`) with:
- profile-based player selection,
- live round sync with Supabase realtime,
- and print/PDF scorecard export.

## 1) Player profiles (dropdown-driven round setup)

### What is implemented
- Players are created once as saved profiles.
- Round setup now uses profile selection only (no hardcoded default players).
- Profile fields are streamlined to:
  - Player Name
  - Abbreviation
  - Notes (optional)
  - Handicap Index (optional)

### Behavior
- Starting a round requires selecting at least two saved profiles.
- Round players are built directly from selected profiles.

---

## 2) Database-backed join code + realtime multi-device tracking

### What is implemented
- Join Code is a database key, not an in-memory channel name.
- `public.live_rounds` stores exactly one row per round:
  - `join_code` (unique, indexed)
  - `snapshot` (authoritative JSON state)
- Every client joins by querying `join_code` and loading the same row.
- Score/setup writes update that same row.
- Realtime listeners subscribe to Postgres `UPDATE` events filtered by `round_id`.

### Setup steps
1. Create a Supabase project.
2. Run `supabase/live_rounds.sql` in the Supabase SQL editor.
3. In `RealtimeService` in `index.html`, set:
   - `SUPABASE_URL` (project URL, no `/rest/v1` suffix)
   - `SUPABASE_ANON_KEY`
4. On one device: click **Generate Code** (creates a DB row and returns Join Code).
5. On other devices: enter code and click **Join Code** (queries DB row + subscribes).
6. Any score change writes snapshot to DB and broadcasts via Realtime to all clients.

### Behavior
- Database is the single source of truth.
- Refreshing either browser rehydrates from the same `snapshot` row.
- No polling is used; updates are realtime Postgres events only.

---

## 3) Save round output

### What is implemented
- Save Round generates a PDF from the same `#scorecard-preview` used by Print.
- Export uses `html2canvas` + `jsPDF` from CDN.

### Notes
- Because it renders from the print DOM, exported output stays visually consistent with the print layout.

---

## Local run
Because this is static HTML, you can open directly in browser or serve with:

```bash
python -m http.server 8080
```

Then open `http://localhost:8080`.
