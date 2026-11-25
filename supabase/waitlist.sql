-- Amorchik waitlist: публичная форма может только добавлять строки, читать — никто кроме владельца (dashboard / service role).
create table if not exists public.amorchik_waitlist (
  id          bigint generated always as identity primary key,
  created_at  timestamptz not null default now(),
  contact     text not null check (char_length(contact) between 3 and 120),
  name        text check (name is null or char_length(name) <= 60),
  stage       text check (stage is null or stage in ('trying','tests','ivf','pregnant','partner','other')),
  source      text check (source is null or char_length(source) <= 40),
  consent     boolean not null check (consent = true)
);

create unique index if not exists amorchik_waitlist_contact_uniq
  on public.amorchik_waitlist (lower(contact));

alter table public.amorchik_waitlist enable row level security;

drop policy if exists "anon can join waitlist" on public.amorchik_waitlist;
create policy "anon can join waitlist"
  on public.amorchik_waitlist
  for insert
  to anon
  with check (consent = true);

revoke select, update, delete on public.amorchik_waitlist from anon, authenticated;
grant insert on public.amorchik_waitlist to anon;
