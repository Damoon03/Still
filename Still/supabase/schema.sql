-- Run this once in the Supabase dashboard: SQL Editor → New query → paste → Run.
-- Every row is scoped to its owner via Row Level Security — enforced
-- at the database layer, not trusted to client code, matching Still's
-- locked-in architecture decision.

create table if not exists public.memories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  place text not null,
  region text not null default '',
  text text not null,
  date timestamptz not null default now(),
  icon text not null default 'mappin',
  is_private boolean not null default true,
  latitude double precision,
  longitude double precision,
  created_at timestamptz not null default now()
);

alter table public.memories enable row level security;

create policy "select own memories"
  on public.memories for select
  using (auth.uid() = user_id);

create policy "insert own memories"
  on public.memories for insert
  with check (auth.uid() = user_id);

create policy "update own memories"
  on public.memories for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "delete own memories"
  on public.memories for delete
  using (auth.uid() = user_id);

-- Not part of this pass, but worth knowing for later: this table
-- deliberately has no relationship to a `friendships` or
-- `discoveries` table yet, and latitude/longitude are plain doubles,
-- not PostGIS geography — proximity-gated discovery (Layer 10) is
-- where that upgrade belongs, once Friends/Discoveries stop being mock.
