-- Multiplayer foundation table for PlayPal.
-- Join Code is stored once per round and is the deterministic lookup key.

create table if not exists public.live_rounds (
  id uuid primary key default gen_random_uuid(),
  join_code text not null,
  snapshot jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists live_rounds_join_code_uidx
  on public.live_rounds (join_code);

create index if not exists live_rounds_updated_at_idx
  on public.live_rounds (updated_at desc);

create or replace function public.set_live_rounds_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_live_rounds_updated_at on public.live_rounds;
create trigger trg_live_rounds_updated_at
before update on public.live_rounds
for each row
execute function public.set_live_rounds_updated_at();

alter table public.live_rounds replica identity full;
alter publication supabase_realtime add table public.live_rounds;

-- RLS example for an anonymous front-end app. Tighten this for production auth.
alter table public.live_rounds enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'live_rounds'
      and policyname = 'live_rounds_public_read'
  ) then
    create policy live_rounds_public_read on public.live_rounds
      for select using (true);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'live_rounds'
      and policyname = 'live_rounds_public_insert'
  ) then
    create policy live_rounds_public_insert on public.live_rounds
      for insert with check (true);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'live_rounds'
      and policyname = 'live_rounds_public_update'
  ) then
    create policy live_rounds_public_update on public.live_rounds
      for update using (true) with check (true);
  end if;
end$$;
