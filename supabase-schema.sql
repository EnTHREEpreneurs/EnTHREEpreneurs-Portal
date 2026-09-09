-- EnTHREEpreneurs Class Portal — Supabase schema
-- Run this entire file in Supabase SQL Editor after creating a project.

create extension if not exists pgcrypto;

create table if not exists public.admins (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  email text,
  role text not null check (role in ('OWNER','PRESIDENT','VICE_PRESIDENT')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.subjects (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  icon text default '📚',
  description text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.schedules (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid references public.subjects(id) on delete set null,
  subject_name text,
  professor text not null,
  day text not null,
  start_time text not null,
  end_time text not null,
  platform text,
  meeting_link text,
  room text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.resources (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid references public.subjects(id) on delete set null,
  subject_name text,
  title text not null,
  type text not null default 'Other',
  description text,
  resource_url text,
  storage_path text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.activities (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid references public.subjects(id) on delete set null,
  subject_name text,
  title text not null,
  professor text,
  assigned_date date,
  deadline timestamptz,
  description text,
  submission_method text,
  submission_link text,
  attachment_url text,
  storage_path text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  date date not null,
  time text,
  location text,
  description text,
  link text,
  image_url text,
  storage_path text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.pup_calendar (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  date date not null,
  category text,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.announcements (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  date text,
  message text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.funds (
  id uuid primary key default gen_random_uuid(),
  date date not null,
  description text not null,
  income numeric(12,2) not null default 0,
  expense numeric(12,2) not null default 0,
  category text,
  receipt_url text,
  storage_path text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.contacts (
  id uuid primary key default gen_random_uuid(),
  category text not null check (category in ('officer','university')),
  name text not null,
  position text,
  email text,
  office text,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.feedback (
  id uuid primary key default gen_random_uuid(),
  name text not null default 'Anonymous',
  rating text,
  message text not null,
  status text not null default 'New',
  created_at timestamptz not null default now()
);

create table if not exists public.concerns (
  id uuid primary key default gen_random_uuid(),
  name text not null default 'Anonymous',
  category text,
  urgency text,
  message text not null,
  status text not null default 'New',
  created_at timestamptz not null default now()
);

-- Helper functions. SECURITY DEFINER prevents admin checks from recursively
-- evaluating the admins table's own RLS policy.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.admins
    where id = auth.uid()
  );
$$;

create or replace function public.is_owner()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.admins
    where id = auth.uid() and role = 'OWNER'
  );
$$;

-- Enable RLS on every exposed table.
alter table public.admins enable row level security;
alter table public.subjects enable row level security;
alter table public.schedules enable row level security;
alter table public.resources enable row level security;
alter table public.activities enable row level security;
alter table public.events enable row level security;
alter table public.pup_calendar enable row level security;
alter table public.announcements enable row level security;
alter table public.funds enable row level security;
alter table public.contacts enable row level security;
alter table public.feedback enable row level security;
alter table public.concerns enable row level security;

-- Remove only this portal's policies if the script is re-run.
do $$
declare t text; p text;
begin
  foreach t in array array['admins','subjects','schedules','resources','activities','events','pup_calendar','announcements','funds','contacts','feedback','concerns'] loop
    for p in select policyname from pg_policies where schemaname='public' and tablename=t loop
      execute format('drop policy if exists %I on public.%I', p, t);
    end loop;
  end loop;
end $$;

-- Admin roster: admins can read; Owner alone can mutate.
create policy admins_select on public.admins for select to authenticated using (public.is_admin());
create policy admins_insert on public.admins for insert to authenticated with check (public.is_owner());
create policy admins_update on public.admins for update to authenticated using (public.is_owner()) with check (public.is_owner());
create policy admins_delete on public.admins for delete to authenticated using (public.is_owner());

-- Public content: anyone can read; admins can mutate.

do $$
declare t text;
begin
  foreach t in array array['subjects','schedules','resources','activities','events','pup_calendar','announcements','funds','contacts'] loop
    execute format('create policy %I on public.%I for select to anon, authenticated using (true)', t || '_public_read', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (public.is_admin())', t || '_admin_insert', t);
    execute format('create policy %I on public.%I for update to authenticated using (public.is_admin()) with check (public.is_admin())', t || '_admin_update', t);
    execute format('create policy %I on public.%I for delete to authenticated using (public.is_admin())', t || '_admin_delete', t);
  end loop;
end $$;

-- Public forms: anyone may submit; only admins can read/change/delete.
create policy feedback_public_insert on public.feedback for insert to anon, authenticated with check (true);
create policy feedback_admin_select on public.feedback for select to authenticated using (public.is_admin());
create policy feedback_admin_update on public.feedback for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy feedback_admin_delete on public.feedback for delete to authenticated using (public.is_admin());

create policy concerns_public_insert on public.concerns for insert to anon, authenticated with check (true);
create policy concerns_admin_select on public.concerns for select to authenticated using (public.is_admin());
create policy concerns_admin_update on public.concerns for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy concerns_admin_delete on public.concerns for delete to authenticated using (public.is_admin());

-- Public Storage bucket for class files. Files are readable by students;
-- only admins can upload, update, or delete.
insert into storage.buckets (id, name, public)
values ('class-files', 'class-files', true)
on conflict (id) do update set public = true;

drop policy if exists class_files_public_read on storage.objects;
drop policy if exists class_files_admin_insert on storage.objects;
drop policy if exists class_files_admin_update on storage.objects;
drop policy if exists class_files_admin_delete on storage.objects;

create policy class_files_public_read
on storage.objects for select
to anon, authenticated
using (bucket_id = 'class-files');

create policy class_files_admin_insert
on storage.objects for insert
to authenticated
with check (bucket_id = 'class-files' and public.is_admin());

create policy class_files_admin_update
on storage.objects for update
to authenticated
using (bucket_id = 'class-files' and public.is_admin())
with check (bucket_id = 'class-files' and public.is_admin());

create policy class_files_admin_delete
on storage.objects for delete
to authenticated
using (bucket_id = 'class-files' and public.is_admin());

-- Starter subjects. Safe to run once; names are unique only logically, so this
-- inserts them only when the table is empty.
insert into public.subjects (name, icon, description, active)
select * from (values
  ('Panitikang Filipino','📖','Learning materials and activities for Panitikang Filipino.',true),
  ('Opportunity Seeking','🎯','Learning materials and activities for Opportunity Seeking.',true),
  ('Innovation Management','💡','Learning materials and activities for Innovation Management.',true),
  ('Ethics','⚖️','Learning materials and activities for Ethics.',true),
  ('Science, Technology and Society','🔬','Learning materials and activities for Science, Technology and Society.',true),
  ('Life and Works of Rizal','📜','Learning materials and activities for Life and Works of Rizal.',true),
  ('Physical Activity Towards Health and Fitness 3','🏃','Learning materials and activities for Physical Activity Towards Health and Fitness 3.',true)
) as v(name,icon,description,active)
where not exists (select 1 from public.subjects);

-- IMPORTANT: bootstrap your Owner after creating your Supabase Auth user.
-- Replace the UUID and name/email, then run this statement in SQL Editor.
-- insert into public.admins (id, name, email, role)
-- values ('YOUR-SUPABASE-AUTH-USER-UUID', 'Your Name', 'your@email.com', 'OWNER')
-- on conflict (id) do update set name=excluded.name, email=excluded.email, role=excluded.role;
