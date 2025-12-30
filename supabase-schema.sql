-- =====================================================
-- SALES INTELLIGENCE AGENT - COMPLETE DATABASE SCHEMA
-- December 2025 - Modernized Version
-- =====================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "vector";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- =====================================================
-- ENUMS
-- =====================================================

CREATE TYPE call_type AS ENUM (
  'Prospect discovery',
  'Prospect demo', 
  'Prospect objections',
  'Prospect negotiations',
  'Prospect closing',
  'Client onboarding',
  'Client checkin',
  'Client upsell',
  'Client renewal',
  'Client support',
  'Partner strategy',
  'Partner joint meeting',
  'Partner training',
  'Partner referral',
  'Internal sales meeting',
  'Internal coaching',
  'Internal pipeline review',
  'Internal strategy',
  'Investor update',
  'Investor board presentation',
  'Investor advisory',
  'Other no show',
  'Other technical issue',
  'Other cancelled'
);

CREATE TYPE source_type AS ENUM (
  'attention',
  'fireflies',
  'manual',
  'zoom',
  'teams'
);

CREATE TYPE team_role AS ENUM (
  'owner',
  'admin',
  'member',
  'viewer'
);

CREATE TYPE subscription_plan AS ENUM (
  'free',
  'starter',
  'professional',
  'enterprise'
);

-- =====================================================
-- CORE TABLES
-- =====================================================

-- Teams table (multi-tenancy)
CREATE TABLE public.teams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Basic info
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  
  -- Subscription
  plan subscription_plan DEFAULT 'free',
  subscription_status TEXT,
  stripe_customer_id TEXT,
  
  -- Settings
  settings JSONB DEFAULT '{}'::jsonb,
  
  -- Soft delete
  deleted_at TIMESTAMPTZ
);

-- Team members (user access control)
CREATE TABLE public.team_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  role team_role NOT NULL DEFAULT 'member',
  
  UNIQUE(team_id, user_id)
);

-- Raw transcripts (from Attention/Fireflies)
CREATE TABLE public.transcripts_raw (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Team association
  team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
  
  -- Source metadata
  source source_type NOT NULL DEFAULT 'attention',
  source_id TEXT NOT NULL,
  source_url TEXT,
  
  -- Meeting metadata
  title TEXT NOT NULL,
  date TIMESTAMPTZ NOT NULL,
  duration_seconds INTEGER,
  
  -- Raw data from API
  raw_data JSONB NOT NULL,
  
  -- Processing status
  is_valid BOOLEAN DEFAULT NULL,
  is_processed BOOLEAN DEFAULT FALSE,
  processing_error TEXT,
  processing_started_at TIMESTAMPTZ,
  processing_completed_at TIMESTAMPTZ,
  
  -- Soft delete
  deleted_at TIMESTAMPTZ,
  
  UNIQUE(source, source_id)
);

-- Processed transcripts (cleaned and structured)
CREATE TABLE public.transcripts_processed (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Team association
  team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
  
  -- Relations
  original_transcript_id UUID REFERENCES transcripts_raw(id) ON DELETE SET NULL,
  
  -- Metadata
  title TEXT NOT NULL,
  date TIMESTAMPTZ NOT NULL,
  duration_seconds INTEGER,
  type call_type,
  
  -- Structured data
  speakers JSONB NOT NULL DEFAULT '[]'::jsonb,
  accounts JSONB NOT NULL DEFAULT '[]'::jsonb,
  competitors JSONB DEFAULT '[]'::jsonb,
  partners JSONB DEFAULT '[]'::jsonb,
  segments JSONB NOT NULL DEFAULT '[]'::jsonb,
  
  -- AI-generated summaries
  summaries JSONB DEFAULT '{}'::jsonb,
  custom_summaries JSONB DEFAULT '{}'::jsonb,
  
  -- Analytics & metrics
  sentiment JSONB,
  analytics JSONB,
  custom_metrics JSONB,
  
  -- Processing flags
  is_valid BOOLEAN DEFAULT TRUE,
  is_summarized BOOLEAN DEFAULT FALSE,
  is_vectorized BOOLEAN DEFAULT FALSE,
  
  -- Full-text search
  search_vector tsvector GENERATED ALWAYS AS (
    to_tsvector('english', 
      coalesce(title, '') || ' ' || 
      coalesce((summaries->>'overview')::text, '') || ' ' ||
      coalesce((custom_summaries->>'overview')::text, '')
    )
  ) STORED,
  
  -- Soft delete
  deleted_at TIMESTAMPTZ
);

-- Vectorized chunks (for RAG)
CREATE TABLE public.transcripts_vectorized (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Team association
  team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
  
  -- Content
  content TEXT NOT NULL,
  metadata JSONB NOT NULL,
  
  -- Vector embedding
  -- Use 1536 for text-embedding-3-small, 3072 for text-embedding-3-large
  embedding VECTOR(1536) NOT NULL,
  
  CONSTRAINT content_not_empty CHECK (char_length(content) > 0)
);

-- Contacts/CRM (prospects, employers, partners)
CREATE TABLE public.contacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Team association
  team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
  
  -- Basic info
  email TEXT UNIQUE NOT NULL,
  first_name TEXT,
  last_name TEXT,
  title TEXT,
  organization TEXT,
  role TEXT,
  
  -- Account association
  account_id UUID,
  
  -- Metadata
  is_sales BOOLEAN DEFAULT FALSE,
  metadata JSONB DEFAULT '{}'::jsonb,
  
  -- Soft delete
  deleted_at TIMESTAMPTZ
);

-- Sales team members
CREATE TABLE public.team_sales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Team association
  team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
  
  -- Basic info
  email TEXT UNIQUE NOT NULL,
  first_name TEXT,
  last_name TEXT,
  title TEXT,
  
  -- Status
  is_active BOOLEAN DEFAULT TRUE,
  is_sales BOOLEAN DEFAULT TRUE,
  
  -- Metadata
  metadata JSONB DEFAULT '{}'::jsonb,
  
  -- Soft delete
  deleted_at TIMESTAMPTZ
);

-- Agent interaction logs (for analytics and improvement)
CREATE TABLE public.agent_interactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Team and user context
  team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  session_id TEXT NOT NULL,
  
  -- Query details
  query TEXT NOT NULL,
  intent TEXT,
  
  -- Response
  response JSONB NOT NULL,
  
  -- Performance metrics
  latency_ms INTEGER,
  tokens_used INTEGER,
  model_used TEXT,
  cost_usd DECIMAL(10, 6),
  
  -- Feedback (for RLHF)
  user_rating INTEGER CHECK (user_rating BETWEEN 1 AND 5),
  user_feedback TEXT,
  feedback_provided_at TIMESTAMPTZ,
  
  -- Tool usage tracking
  tools_used JSONB,
  search_results_count INTEGER,
  
  -- Context
  conversation_history JSONB
);

-- API usage tracking (for billing)
CREATE TABLE public.api_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  
  team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
  
  -- Usage metrics
  transcripts_processed INTEGER DEFAULT 0,
  embeddings_created INTEGER DEFAULT 0,
  agent_queries INTEGER DEFAULT 0,
  tokens_used INTEGER DEFAULT 0,
  
  -- Cost tracking
  estimated_cost_usd DECIMAL(10, 4),
  
  UNIQUE(team_id, date)
);

-- System logs
CREATE TABLE public.logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Log details
  level TEXT NOT NULL, -- info, warn, error
  author TEXT,
  title TEXT,
  message TEXT,
  payload JSONB,
  
  -- Context
  team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
  workflow_id TEXT,
  execution_id TEXT
);

-- =====================================================
-- INDEXES
-- =====================================================

-- Teams
CREATE INDEX idx_teams_slug ON teams(slug);
CREATE INDEX idx_teams_plan ON teams(plan);

-- Team members
CREATE INDEX idx_team_members_user ON team_members(user_id);
CREATE INDEX idx_team_members_team ON team_members(team_id);

-- Raw transcripts
CREATE INDEX idx_transcripts_raw_team ON transcripts_raw(team_id);
CREATE INDEX idx_transcripts_raw_source ON transcripts_raw(source, source_id);
CREATE INDEX idx_transcripts_raw_date ON transcripts_raw(date DESC);
CREATE INDEX idx_transcripts_raw_processing ON transcripts_raw(is_processed) 
  WHERE is_processed = FALSE;

-- Processed transcripts
CREATE INDEX idx_transcripts_processed_team ON transcripts_processed(team_id);
CREATE INDEX idx_transcripts_processed_date ON transcripts_processed(date DESC);
CREATE INDEX idx_transcripts_processed_type ON transcripts_processed(type);
CREATE INDEX idx_transcripts_processed_search ON transcripts_processed 
  USING gin(search_vector);
CREATE INDEX idx_transcripts_processed_summarized ON transcripts_processed(is_summarized) 
  WHERE is_summarized = FALSE;
CREATE INDEX idx_transcripts_processed_vectorized ON transcripts_processed(is_vectorized) 
  WHERE is_vectorized = FALSE;

-- Vectorized transcripts (HNSW for fast similarity search)
CREATE INDEX idx_vectorized_team ON transcripts_vectorized(team_id);
CREATE INDEX idx_vectorized_embedding ON transcripts_vectorized 
  USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64);

-- Metadata indexes for filtering
CREATE INDEX idx_vectorized_parent ON transcripts_vectorized ((metadata->>'parent_id'));
CREATE INDEX idx_vectorized_type ON transcripts_vectorized ((metadata->>'vector_type'));
CREATE INDEX idx_vectorized_date ON transcripts_vectorized ((metadata->>'date'));
CREATE INDEX idx_vectorized_call_type ON transcripts_vectorized ((metadata->>'call_type'));

-- Contacts
CREATE INDEX idx_contacts_team ON contacts(team_id);
CREATE INDEX idx_contacts_email ON contacts(email);
CREATE INDEX idx_contacts_org ON contacts(organization);

-- Team sales
CREATE INDEX idx_team_sales_team ON team_sales(team_id);
CREATE INDEX idx_team_sales_email ON team_sales(email);

-- Agent interactions
CREATE INDEX idx_agent_interactions_team ON agent_interactions(team_id);
CREATE INDEX idx_agent_interactions_user ON agent_interactions(user_id, created_at DESC);
CREATE INDEX idx_agent_interactions_session ON agent_interactions(session_id);
CREATE INDEX idx_agent_interactions_rating ON agent_interactions(user_rating) 
  WHERE user_rating IS NOT NULL;
CREATE INDEX idx_agent_interactions_created ON agent_interactions(created_at DESC);

-- API usage
CREATE INDEX idx_api_usage_team ON api_usage(team_id, date DESC);

-- Logs
CREATE INDEX idx_logs_team ON logs(team_id);
CREATE INDEX idx_logs_level ON logs(level);
CREATE INDEX idx_logs_created ON logs(created_at DESC);

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Updated timestamp trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to relevant tables
CREATE TRIGGER update_teams_updated_at
  BEFORE UPDATE ON teams
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_team_members_updated_at
  BEFORE UPDATE ON team_members
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_transcripts_raw_updated_at
  BEFORE UPDATE ON transcripts_raw
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_transcripts_processed_updated_at
  BEFORE UPDATE ON transcripts_processed
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_contacts_updated_at
  BEFORE UPDATE ON contacts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_team_sales_updated_at
  BEFORE UPDATE ON team_sales
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Generic vector search function (for RAG pipeline)
CREATE OR REPLACE FUNCTION search_transcripts(
  query_embedding vector(1536),
  match_threshold float DEFAULT 0.3,
  match_count int DEFAULT 10,
  from_date date DEFAULT NULL,
  to_date date DEFAULT NULL,
  filter_team_id uuid DEFAULT NULL
)
RETURNS TABLE(
  id uuid,
  content text,
  metadata jsonb,
  similarity float
) 
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
  SELECT 
    t.id,
    t.content,
    t.metadata,
    1 - (t.embedding <=> query_embedding) as similarity
  FROM transcripts_vectorized t
  WHERE 1 - (t.embedding <=> query_embedding) > match_threshold
    AND (filter_team_id IS NULL OR t.team_id = filter_team_id)
    AND (from_date IS NULL OR (t.metadata->>'date')::date >= from_date)
    AND (to_date IS NULL OR (t.metadata->>'date')::date <= to_date)
  ORDER BY t.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

-- Vector search function (summaries)
CREATE OR REPLACE FUNCTION search_summaries(
  query_embedding vector(1536),
  match_threshold float DEFAULT 0.5,
  match_count int DEFAULT 100,
  from_date date DEFAULT NULL,
  to_date date DEFAULT NULL,
  parent_ids text[] DEFAULT NULL,
  summary_types text[] DEFAULT NULL,
  call_types text[] DEFAULT NULL,
  accounts text[] DEFAULT NULL,
  competitors text[] DEFAULT NULL,
  speaker_names text[] DEFAULT NULL,
  speaker_emails text[] DEFAULT NULL,
  speaker_roles text[] DEFAULT NULL,
  speaker_organizations text[] DEFAULT NULL,
  filter_team_id uuid DEFAULT NULL
)
RETURNS TABLE(
  id uuid,
  content text,
  metadata jsonb,
  similarity float
) 
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
  SELECT 
    t.id,
    t.content,
    t.metadata,
    1 - (t.embedding <=> query_embedding) as similarity
  FROM transcripts_vectorized t
  WHERE 1 - (t.embedding <=> query_embedding) > match_threshold
    AND (filter_team_id IS NULL OR t.team_id = filter_team_id)
    AND (from_date IS NULL OR (t.metadata->>'date')::date >= from_date)
    AND (to_date IS NULL OR (t.metadata->>'date')::date <= to_date)
    AND (parent_ids IS NULL OR t.metadata->>'parent_id' = ANY(parent_ids))
    AND (summary_types IS NULL OR t.metadata->>'summary_type' = ANY(summary_types))
    AND (call_types IS NULL OR t.metadata->>'call_type' = ANY(call_types))
    AND (accounts IS NULL OR t.metadata->'accounts' ?| accounts)
    AND (competitors IS NULL OR t.metadata->'competitors' ?| competitors)
    AND (speaker_names IS NULL OR EXISTS (
      SELECT 1 FROM jsonb_array_elements(t.metadata->'speakers') AS speaker
      WHERE speaker->>'name' = ANY(speaker_names)
    ))
    AND (speaker_emails IS NULL OR EXISTS (
      SELECT 1 FROM jsonb_array_elements(t.metadata->'speakers') AS speaker
      WHERE speaker->>'email' = ANY(speaker_emails)
    ))
    AND (speaker_roles IS NULL OR EXISTS (
      SELECT 1 FROM jsonb_array_elements(t.metadata->'speakers') AS speaker
      WHERE speaker->>'role' = ANY(speaker_roles)
    ))
    AND (speaker_organizations IS NULL OR EXISTS (
      SELECT 1 FROM jsonb_array_elements(t.metadata->'speakers') AS speaker
      WHERE speaker->>'organization' = ANY(speaker_organizations)
    ))
    AND t.metadata->>'vector_type' = 'transcript_summary'
  ORDER BY t.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

-- Vector search function (segments)
CREATE OR REPLACE FUNCTION search_segments(
  query_embedding vector(1536),
  match_threshold float DEFAULT 0.5,
  match_count int DEFAULT 150,
  from_date date DEFAULT NULL,
  to_date date DEFAULT NULL,
  call_types text[] DEFAULT NULL,
  accounts text[] DEFAULT NULL,
  competitors text[] DEFAULT NULL,
  speaker_names text[] DEFAULT NULL,
  current_speaker_names text[] DEFAULT NULL,
  current_speaker_roles text[] DEFAULT NULL,
  filter_team_id uuid DEFAULT NULL
)
RETURNS TABLE(
  id uuid,
  content text,
  metadata jsonb,
  similarity float
) 
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
  SELECT 
    t.id,
    t.content,
    t.metadata,
    1 - (t.embedding <=> query_embedding) as similarity
  FROM transcripts_vectorized t
  WHERE 1 - (t.embedding <=> query_embedding) > match_threshold
    AND (filter_team_id IS NULL OR t.team_id = filter_team_id)
    AND (from_date IS NULL OR (t.metadata->>'date')::date >= from_date)
    AND (to_date IS NULL OR (t.metadata->>'date')::date <= to_date)
    AND (call_types IS NULL OR t.metadata->>'call_type' = ANY(call_types))
    AND (accounts IS NULL OR t.metadata->'accounts' ?| accounts)
    AND (competitors IS NULL OR t.metadata->'competitors' ?| competitors)
    AND (speaker_names IS NULL OR EXISTS (
      SELECT 1 FROM jsonb_array_elements(t.metadata->'speakers') AS speaker
      WHERE speaker->>'name' = ANY(speaker_names)
    ))
    AND (current_speaker_names IS NULL OR t.metadata->'current_speaker'->>'name' = ANY(current_speaker_names))
    AND (current_speaker_roles IS NULL OR t.metadata->'current_speaker'->>'role' = ANY(current_speaker_roles))
    AND t.metadata->>'vector_type' = 'transcript_segment'
  ORDER BY t.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE transcripts_raw ENABLE ROW LEVEL SECURITY;
ALTER TABLE transcripts_processed ENABLE ROW LEVEL SECURITY;
ALTER TABLE transcripts_vectorized ENABLE ROW LEVEL SECURITY;
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE api_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE logs ENABLE ROW LEVEL SECURITY;

-- Teams: Users can only see teams they're members of
CREATE POLICY "Users can view their teams"
  ON teams FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM team_members
      WHERE team_members.team_id = teams.id
      AND team_members.user_id = auth.uid()
    )
  );

-- Team members: Users can view members of their teams
CREATE POLICY "Users can view team members"
  ON team_members FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM team_members tm
      WHERE tm.team_id = team_members.team_id
      AND tm.user_id = auth.uid()
    )
  );

-- Transcripts: Team-based access
CREATE POLICY "Users can view their team's raw transcripts"
  ON transcripts_raw FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM team_members
      WHERE team_members.team_id = transcripts_raw.team_id
      AND team_members.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can view their team's processed transcripts"
  ON transcripts_processed FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM team_members
      WHERE team_members.team_id = transcripts_processed.team_id
      AND team_members.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can view their team's vectorized data"
  ON transcripts_vectorized FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM team_members
      WHERE team_members.team_id = transcripts_vectorized.team_id
      AND team_members.user_id = auth.uid()
    )
  );

-- Agent interactions: Users can only see their own interactions
CREATE POLICY "Users can view their own agent interactions"
  ON agent_interactions FOR SELECT
  USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM team_members
      WHERE team_members.team_id = agent_interactions.team_id
      AND team_members.user_id = auth.uid()
      AND team_members.role IN ('owner', 'admin')
    )
  );

-- =====================================================
-- SAMPLE DATA (for development)
-- =====================================================

-- Insert sample team
INSERT INTO teams (id, name, slug, plan) VALUES
  ('00000000-0000-0000-0000-000000000001', 'Demo Sales Team', 'demo', 'professional');

-- Insert sample team member (replace with your user ID)
-- INSERT INTO team_members (team_id, user_id, role) VALUES
--   ('00000000-0000-0000-0000-000000000001', 'your-user-id-here', 'owner');

-- =====================================================
-- VIEWS (for convenience)
-- =====================================================

-- Recent transcripts with key metrics
CREATE OR REPLACE VIEW recent_transcripts AS
SELECT 
  tp.id,
  tp.title,
  tp.date,
  tp.type,
  tp.duration_seconds,
  tp.is_summarized,
  tp.is_vectorized,
  (tp.custom_metrics->>'sentiment')::float as sentiment_score,
  (tp.custom_metrics->>'velocity')::float as velocity_score,
  jsonb_array_length(tp.speakers) as speaker_count,
  jsonb_array_length(tp.accounts) as account_count,
  tp.team_id
FROM transcripts_processed tp
WHERE tp.deleted_at IS NULL
ORDER BY tp.date DESC;

-- Agent performance metrics
CREATE OR REPLACE VIEW agent_performance AS
SELECT 
  date_trunc('day', created_at) as day,
  team_id,
  COUNT(*) as total_queries,
  AVG(latency_ms) as avg_latency_ms,
  SUM(tokens_used) as total_tokens,
  SUM(cost_usd) as total_cost_usd,
  AVG(CASE WHEN user_rating IS NOT NULL THEN user_rating END) as avg_rating,
  COUNT(CASE WHEN user_rating IS NOT NULL THEN 1 END) as ratings_count
FROM agent_interactions
GROUP BY date_trunc('day', created_at), team_id
ORDER BY day DESC;

-- =====================================================
-- COMPLETION MESSAGE
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '✅ Sales Intelligence Agent schema created successfully!';
  RAISE NOTICE '📊 Created tables: teams, team_members, transcripts_raw, transcripts_processed, transcripts_vectorized, contacts, team_sales, agent_interactions, api_usage, logs';
  RAISE NOTICE '🔒 Row Level Security enabled on all tables';
  RAISE NOTICE '🔍 Vector search functions created: search_summaries(), search_segments()';
  RAISE NOTICE '📈 Views created: recent_transcripts, agent_performance';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️  Next steps:';
  RAISE NOTICE '1. Update team_members table with your user ID';
  RAISE NOTICE '2. Configure Supabase Auth';
  RAISE NOTICE '3. Set up API credentials in Supabase Vault';
  RAISE NOTICE '4. Run migrations for n8n workflows';
END $$;

