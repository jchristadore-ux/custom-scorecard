# Supabase Setup for Live Round Join Codes

This app uses `public.live_rounds` as the authoritative source of multiplayer state.

## Step 1 — Tables

Create the table and constraints (or run `supabase/live_rounds.sql`):

```sql
create extension if not exists pgcrypto;

create table if not exists public.live_rounds (
  id uuid primary key default gen_random_uuid(),
  join_code text not null unique,
  snapshot jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

Recommended support objects:

- Unique index on `join_code` (if not already created via `unique` constraint).
- Trigger to auto-update `updated_at` on every update.

## Step 2 — Enable Realtime

In Supabase Dashboard:

1. Open **Database → Replication**.
2. Enable replication for table **`public.live_rounds`**.
3. Ensure `REPLICA IDENTITY FULL` is set for robust payloads.

## Step 3 — RLS Policies

Enable RLS and add policies so the web app can function for `anon` and authenticated users:

- `SELECT` policy (`using (true)`) for reading rounds by `join_code`
- `INSERT` policy (`with check (true)`) for creating rounds
- `UPDATE` policy (`using (true) with check (true)`) for publishing snapshot updates

Also grant table privileges to `anon` and `authenticated` roles.

## Step 4 — Schema Refresh

After creating/updating schema objects, run:

```sql
notify pgrst, 'reload schema';
```

This refreshes PostgREST schema cache so `live_rounds` is immediately queryable from Supabase JS.
