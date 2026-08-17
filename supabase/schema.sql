-- Dietario · Supabase schema
-- Run this in Supabase SQL editor (https://app.supabase.com/project/_/sql)

-- =========================================================
-- Households (a couple / group that shares one weekly plan)
-- =========================================================
create table if not exists public.households (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  invite_code text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.household_members (
  household_id uuid references public.households(id) on delete cascade not null,
  user_id uuid references auth.users(id) on delete cascade not null,
  joined_at timestamptz not null default now(),
  primary key (household_id, user_id)
);

-- =========================================================
-- Domain tables (one row per plan item, scoped to a household)
-- =========================================================
create table if not exists public.day_meals (
  id uuid primary key default gen_random_uuid(),
  household_id uuid references public.households(id) on delete cascade not null,
  day text not null,
  slot text not null,
  text text not null,
  menu_code text,
  note text,
  order_index int not null,
  updated_at timestamptz not null default now()
);
create index if not exists day_meals_household_idx on public.day_meals(household_id);

create table if not exists public.shopping_items (
  id uuid primary key default gen_random_uuid(),
  household_id uuid references public.households(id) on delete cascade not null,
  category text not null,
  product text not null,
  quantity real not null,
  unit text not null,
  notes text not null,
  status text not null default 'pendiente',
  order_index int not null,
  updated_at timestamptz not null default now()
);
create index if not exists shopping_items_household_idx on public.shopping_items(household_id);

create table if not exists public.recipes (
  id uuid primary key default gen_random_uuid(),
  household_id uuid references public.households(id) on delete cascade not null,
  day text not null,
  meal text not null,
  name text not null,
  ingredients text not null,
  preparation text not null,
  origin text not null,
  order_index int not null,
  updated_at timestamptz not null default now()
);
create index if not exists recipes_household_idx on public.recipes(household_id);

create table if not exists public.prep_tasks (
  id uuid primary key default gen_random_uuid(),
  household_id uuid references public.households(id) on delete cascade not null,
  order_index int not null,
  task text not null,
  quantity text not null,
  purpose text not null,
  storage text not null,
  status text not null default 'pendiente',
  updated_at timestamptz not null default now()
);
create index if not exists prep_tasks_household_idx on public.prep_tasks(household_id);

create table if not exists public.plan_notes (
  id uuid primary key default gen_random_uuid(),
  household_id uuid references public.households(id) on delete cascade not null,
  topic text not null,
  respected text not null,
  applied text not null,
  source text not null,
  order_index int not null,
  updated_at timestamptz not null default now()
);
create index if not exists plan_notes_household_idx on public.plan_notes(household_id);

-- =========================================================
-- Row Level Security
-- =========================================================
alter table public.households enable row level security;
alter table public.household_members enable row level security;
alter table public.day_meals enable row level security;
alter table public.shopping_items enable row level security;
alter table public.recipes enable row level security;
alter table public.prep_tasks enable row level security;
alter table public.plan_notes enable row level security;

-- Helper: is the current user a member of a household?
create or replace function public.is_household_member(household uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.household_members
    where household_id = household and user_id = auth.uid()
  );
$$;

-- households: any authenticated user can SELECT (to look one up by invite code);
-- only members can UPDATE; only creator can DELETE.
create policy "households_select_all"
  on public.households for select
  to authenticated
  using (true);

create policy "households_insert_self"
  on public.households for insert
  to authenticated
  with check (true);

create policy "households_update_member"
  on public.households for update
  to authenticated
  using (public.is_household_member(id))
  with check (public.is_household_member(id));

create policy "households_delete_member"
  on public.households for delete
  to authenticated
  using (public.is_household_member(id));

-- household_members: visible if you belong to the household; you can insert
-- your own membership; admins (anyone) can delete.
create policy "members_select_same_household"
  on public.household_members for select
  to authenticated
  using (public.is_household_member(household_id));

create policy "members_insert_self"
  on public.household_members for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "members_delete_self_or_peer"
  on public.household_members for delete
  to authenticated
  using (public.is_household_member(household_id));

-- Domain tables: full CRUD limited to household members.
create policy "day_meals_member_all"
  on public.day_meals for all
  to authenticated
  using (public.is_household_member(household_id))
  with check (public.is_household_member(household_id));

create policy "shopping_items_member_all"
  on public.shopping_items for all
  to authenticated
  using (public.is_household_member(household_id))
  with check (public.is_household_member(household_id));

create policy "recipes_member_all"
  on public.recipes for all
  to authenticated
  using (public.is_household_member(household_id))
  with check (public.is_household_member(household_id));

create policy "prep_tasks_member_all"
  on public.prep_tasks for all
  to authenticated
  using (public.is_household_member(household_id))
  with check (public.is_household_member(household_id));

create policy "plan_notes_member_all"
  on public.plan_notes for all
  to authenticated
  using (public.is_household_member(household_id))
  with check (public.is_household_member(household_id));

-- =========================================================
-- Realtime publication
-- =========================================================
do $$
begin
  if not exists (
    select 1 from pg_publication where pubname = 'supabase_realtime'
  ) then
    create publication supabase_realtime;
  end if;
end $$;

alter publication supabase_realtime add table public.day_meals;
alter publication supabase_realtime add table public.shopping_items;
alter publication supabase_realtime add table public.recipes;
alter publication supabase_realtime add table public.prep_tasks;
alter publication supabase_realtime add table public.plan_notes;
