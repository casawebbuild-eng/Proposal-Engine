-- Proposal Engine: one row per proposal.
create table public.proposals (
  id            bigint generated always as identity primary key,
  proposal_id   text not null unique,              -- CWB-2610-XXXXXX; unique = a retried run can't create a duplicate
  created_at    timestamptz not null default now(),
  is_test       boolean not null default false,    -- runs from the n8n test URL
  status        text not null default 'en_attente'
                check (status in ('en_attente', 'envoyee', 'refusee', 'devis_manuel')),

  contact_name  text,
  contact_email text,
  company       text,
  sector        text,
  goal          text,

  project_type  text,
  clarity       text,
  needs_review  boolean,
  warnings      text[],
  red_flags     text[],

  project_value integer,                           -- internal: what the build is worth
  setup_fee     integer,
  monthly_fee   integer,
  budget_raw    text,
  budget_status text,
  valid_until   timestamptz,

  payload       jsonb                              -- the full proposal object, for debugging
);

-- Row Level Security on, with no policies: nobody can read or write this table
-- through the public API. Only the service role key (stored in n8n) can.
alter table public.proposals enable row level security;
