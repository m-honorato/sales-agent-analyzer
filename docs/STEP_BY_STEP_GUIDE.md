# 🚀 Step-by-Step Implementation Guide

## Welcome! Let's Build Your Sales Intelligence Agent

This guide will take you from **zero to production** in a structured, manageable way.

**Estimated Time**: 2-3 weeks
**Current Status**: Ready to begin!

---

## 📋 Pre-Implementation Checklist

Before we start, make sure you have:

- [ ] Computer with internet access
- [ ] Email address for creating accounts
- [ ] Credit card for API services (most have free tiers)
- [ ] 2-3 hours to dedicate to initial setup

**That's it!** We'll guide you through everything else.

---

## 🎯 Implementation Phases

We'll break this into **6 manageable phases**:

1. **Day 1-2**: Setup & Database (2-3 hours)
2. **Day 3-4**: API Keys & n8n (2-3 hours)
3. **Day 5-7**: First Transcript Test (3-4 hours)
4. **Day 8-12**: Frontend Build (8-10 hours)
5. **Day 13-14**: Integration & Testing (4-5 hours)
6. **Day 15-16**: Deploy & Launch (3-4 hours)

**Total**: ~25-30 hours of focused work

---

# 🟢 PHASE 1: Database Setup (Day 1-2)

## Step 1.1: Create Supabase Account

**Time**: 10 minutes

### Actions:

1. Go to https://supabase.com
2. Click "Start your project"
3. Sign up with GitHub (recommended) or email
4. Verify your email

### Verify:
✅ You should see the Supabase dashboard

---

## Step 1.2: Create New Project

**Time**: 5 minutes (+ 2 min wait for provisioning)

### Actions:

1. Click "New Project"
2. Fill in:
   - **Organization**: Create new (e.g., "Sales Intelligence")
   - **Name**: `sales-intelligence-prod`
   - **Database Password**: Generate strong password
   - **Region**: Choose closest to you
   - **Pricing Plan**: Free (start here, upgrade later)

3. Click "Create new project"
4. **IMPORTANT**: Save these credentials:

```
Project URL: https://xxxxx.supabase.co
Project API Key (anon): eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Database Password: [the password you created]
```

### Verify:
✅ Project shows "Active" status
✅ You have the credentials saved

---

## Step 1.3: Run Database Schema

**Time**: 10 minutes

### Option A: Using SQL Editor (Easiest)

1. In Supabase dashboard, go to **SQL Editor** (left sidebar)
2. Click "New query"
3. Open the file: `supabase-schema.sql` on your computer
4. Copy the entire contents
5. Paste into the SQL editor
6. Click "Run" (bottom right)
7. Wait for completion (should take 30-60 seconds)

### Option B: Using Command Line

```bash
# Install Supabase CLI (if not installed)
npm install -g supabase

# Login
supabase login

# Link your project
supabase link --project-ref your-project-ref

# Run migrations
supabase db push
```

### Verify:

```sql
-- Run this in SQL Editor to check tables were created
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;
```

✅ You should see: `agent_interactions`, `api_usage`, `contacts`, `logs`, `team_members`, `team_sales`, `teams`, `transcripts_processed`, `transcripts_raw`, `transcripts_vectorized`

---

## Step 1.4: Create Your First Team

**Time**: 5 minutes

### Get Your User ID:

1. Go to **Authentication** → **Users** in Supabase
2. Create a test user (if not already logged in):
   - Click "Add user"
   - Email: your-email@example.com
   - Auto-generate password
   - Click "Create user"
3. Copy the **User ID** (UUID format)

### Create Team & Add Yourself:

Run this in SQL Editor:

```sql
-- Create your team
INSERT INTO teams (id, name, slug, plan) VALUES
  (gen_random_uuid(), 'My Sales Team', 'my-team', 'professional');

-- Get the team ID (copy this!)
SELECT id, name FROM teams WHERE slug = 'my-team';

-- Add yourself to the team (replace with your user ID and team ID)
INSERT INTO team_members (team_id, user_id, role) VALUES
  ('TEAM-ID-FROM-ABOVE', 'YOUR-USER-ID', 'owner');
```

### Verify:

```sql
-- Check your team membership
SELECT 
  t.name as team_name,
  tm.role,
  u.email
FROM team_members tm
JOIN teams t ON t.id = tm.team_id
JOIN auth.users u ON u.id = tm.user_id;
```

✅ You should see your team and your email

---

## Step 1.5: Test Vector Search

**Time**: 5 minutes

Let's make sure the vector functions work:

```sql
-- Test the search_summaries function
SELECT search_summaries(
  ARRAY[0.1, 0.2, 0.3]::vector(1536),  -- dummy embedding
  0.1,  -- low threshold for testing
  10    -- return 10 results
);
```

✅ Should execute without errors (may return empty results - that's fine)

---

## 📝 Phase 1 Complete! Checkpoint:

You should now have:
- ✅ Supabase project created
- ✅ Database schema deployed (11 tables)
- ✅ Your team created
- ✅ You added as team owner
- ✅ Vector search functions working

**Save these for later**:
```
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUz...
SUPABASE_SERVICE_ROLE_KEY=[Get from Settings → API]
```

---

# 🔵 PHASE 2: API Keys & n8n Setup (Day 3-4)

## Step 2.1: Get OpenAI API Key (GPT-5.1)

**Time**: 10 minutes

### Actions:

1. Go to https://platform.openai.com
2. Sign up / Log in
3. Go to **API Keys** (left sidebar)
4. Click "Create new secret key"
5. Name: "Sales Intelligence Agent"
6. Click "Create secret key"
7. **COPY IT NOW** (won't be shown again!)

### Add Credits:

1. Go to **Settings** → **Billing**
2. Add $10 to start (enough for ~100 transcripts)
3. Set usage limit: $50/month (safety)

### Verify:

```bash
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer YOUR-API-KEY"
```

✅ Should return a list of models (including gpt-5.1)

**Save**: `OPENAI_API_KEY=sk-proj-...`

---

## Step 2.2: Get Google AI API Key (Gemini 3 Pro)

**Time**: 10 minutes

### Actions:

1. Go to https://ai.google.dev/gemini-api
2. Click "Get API key"
3. Sign in with Google account
4. Click "Create API key"
5. Select "Create API key in new project"
6. Copy the API key

### Verify:

```bash
curl "https://generativelanguage.googleapis.com/v1/models?key=YOUR-API-KEY"
```

✅ Should return list of Gemini models

**Save**: `GOOGLE_AI_API_KEY=AIza...`

---

## Step 2.3: Get Anthropic API Key (Claude)

**Time**: 10 minutes

### Actions:

1. Go to https://console.anthropic.com
2. Sign up / Log in
3. Go to **API Keys**
4. Click "Create Key"
5. Name: "Sales Intelligence"
6. Copy the key

### Add Credits:

1. Go to **Billing**
2. Add $10 credit
3. Set limit: $50/month

### Verify:

```bash
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: YOUR-API-KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 10,
    "messages": [{"role": "user", "content": "Hi"}]
  }'
```

✅ Should return a response

**Save**: `ANTHROPIC_API_KEY=sk-ant-...`

---

## Step 2.4: Get Cohere API Key (Reranking)

**Time**: 5 minutes

### Actions:

1. Go to https://dashboard.cohere.com
2. Sign up with email
3. Go to **API Keys**
4. Copy the "Production" key

### Verify:

```bash
curl -X POST https://api.cohere.ai/v1/rerank \
  -H "Authorization: Bearer YOUR-API-KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "rerank-v3.5",
    "query": "test",
    "documents": ["doc1", "doc2"]
  }'
```

✅ Should return ranking results

**Save**: `COHERE_API_KEY=...`

---

## Step 2.5: Get Attention.tech API Access

**Time**: 15 minutes

### Actions:

1. Go to https://attention.tech
2. Sign up for account
3. Connect your calendar (Google/Outlook)
4. Enable call recording
5. Go to **Settings** → **Integrations** → **API**
6. Click "Generate API Key"
7. Copy API key and Webhook secret

### Test (after first call is recorded):

```bash
curl -X GET "https://api.attention.tech/v1/calls" \
  -H "Authorization: Bearer YOUR-API-KEY"
```

✅ Should return your calls (may be empty initially)

**Save**: 
```
ATTENTION_API_KEY=att_...
ATTENTION_WEBHOOK_SECRET=whsec_...
```

---

## Step 2.6: Set Up n8n

**Time**: 20 minutes

### Option A: n8n Cloud (Recommended for Quick Start)

1. Go to https://n8n.io/cloud
2. Start free trial
3. Create workspace
4. **Save**: `N8N_URL=https://your-name.app.n8n.cloud`

### Option B: Self-Host with Docker

```bash
# Create directory
mkdir n8n-data
cd n8n-data

# Run n8n
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v $(pwd):/home/node/.n8n \
  n8nio/n8n

# Access at: http://localhost:5678
```

### Initial Setup:

1. Create admin account
2. Set up workspace
3. **Note**: Keep this running!

---

## Step 2.7: Add Credentials to n8n

**Time**: 15 minutes

### Add Each Credential:

#### 1. Supabase API

1. In n8n: **Settings** → **Credentials** → **Add Credential**
2. Search: "Supabase"
3. Fill in:
   - Name: `Supabase (Sales Intelligence)`
   - Host: `https://xxxxx.supabase.co`
   - Service Role Secret: `[Your service role key]`
4. Test connection → Save

#### 2. OpenAI API

1. Add Credential → "OpenAI"
2. Fill in:
   - Name: `OpenAI (GPT-5.1)`
   - API Key: `sk-proj-...`
3. Save

#### 3. Google AI (Gemini)

1. Add Credential → "Google AI"
2. Fill in:
   - Name: `Google AI (Gemini 3 Pro)`
   - API Key: `AIza...`
3. Save

#### 4. Anthropic

1. Add Credential → "Anthropic"
2. Fill in:
   - Name: `Anthropic (Claude)`
   - API Key: `sk-ant-...`
3. Save

#### 5. Cohere

1. Add Credential → "Cohere API"
2. Fill in:
   - Name: `Cohere Reranking`
   - API Key: `[Your key]`
3. Save

#### 6. Attention.tech (HTTP Header Auth)

1. Add Credential → "Header Auth"
2. Fill in:
   - Name: `Attention API`
   - Header Name: `Authorization`
   - Header Value: `Bearer YOUR-ATTENTION-KEY`
3. Save

---

## 📝 Phase 2 Complete! Checkpoint:

You should now have:
- ✅ OpenAI API key (GPT-5.1)
- ✅ Google AI API key (Gemini 3 Pro)
- ✅ Anthropic API key (Claude)
- ✅ Cohere API key
- ✅ Attention.tech API access
- ✅ n8n instance running
- ✅ All credentials added to n8n

**Your .env file should have**:
```bash
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...
OPENAI_API_KEY=sk-proj-...
GOOGLE_AI_API_KEY=AIza...
ANTHROPIC_API_KEY=sk-ant-...
COHERE_API_KEY=...
ATTENTION_API_KEY=att_...
```

---

# 🟡 PHASE 3: Import & Test Workflows (Day 5-7)

## Step 3.1: Import First Workflow

**Time**: 10 minutes

Let's start with the simplest workflow to test:

### Actions:

1. In n8n, click **Workflows** → **Add Workflow**
2. Click **⋮** (three dots) → **Import from File**
3. Select: `✍🏻 Log Handler.json`
4. The workflow opens
5. Click **Save**

### Update Credentials:

1. Click on the "Supabase" node (if any)
2. Select your credential: `Supabase (Sales Intelligence)`
3. Save workflow

### Test:

1. Click **Test workflow** button (top right)
2. Click **Execute Workflow**
3. Check the **logs** table in Supabase

✅ Should create a log entry

---

## Step 3.2: Create Attention Fetch Workflow

**Time**: 30 minutes

We need to create a NEW workflow for Attention (replacing Fireflies).

### Actions:

1. Create new workflow: "Fetch Attention Transcript"
2. Add nodes as follows:

#### Node 1: Workflow Trigger

```
Type: Execute Workflow Trigger
Input: 
  - call_id (string)
```

#### Node 2: HTTP Request (Get Call)

```
Type: HTTP Request
Method: GET
URL: =https://api.attention.tech/v1/calls/{{ $json.call_id }}
Authentication: Use Attention API credential
```

#### Node 3: Code (Transform Data)

```javascript
// Copy this code - transforms Attention → our schema
const attentionCall = $json;

// Map participants
const speakers = attentionCall.participants.map((p, index) => ({
  id: index,
  name: p.name,
  email: p.email,
  role: p.role === 'prospect' ? 'Prospect' : 
        p.role === 'seller' ? 'Seller' : 'Team'
}));

// Map segments
const segments = attentionCall.transcript.segments.map(seg => {
  const speakerIndex = speakers.findIndex(s => s.name === seg.speaker);
  return {
    speaker_id: speakerIndex,
    speaker_name: seg.speaker,
    text: seg.text,
    start_time: formatTime(seg.start_time),
    ai_filters: {
      text_cleanup: seg.text,
      sentiment: seg.sentiment || null
    }
  };
});

function formatTime(seconds) {
  const h = Math.floor(seconds / 3600).toString().padStart(2, '0');
  const m = Math.floor((seconds % 3600) / 60).toString().padStart(2, '0');
  const s = Math.floor(seconds % 60).toString().padStart(2, '0');
  return `${h}:${m}:${s}`;
}

return {
  data: {
    transcript: {
      id: attentionCall.call_id,
      title: attentionCall.title,
      dateString: attentionCall.start_time,
      duration: attentionCall.duration_seconds / 60,
      participants: speakers.map(s => s.email),
      speakers: speakers,
      sentences: segments
    }
  }
};
```

#### Node 4: Supabase (Save Raw)

```
Type: Supabase
Operation: Insert
Table: transcripts_raw
Fields:
  - source: 'attention'
  - source_id: ={{ $json.data.transcript.id }}
  - title: ={{ $json.data.transcript.title }}
  - date: ={{ $json.data.transcript.dateString }}
  - raw_data: ={{ $json.data.transcript }}
  - team_id: [Your team ID from Step 1.4]
```

3. **Save workflow**
4. **Activate workflow** (toggle switch top right)

---

## Step 3.3: Test with Real Call

**Time**: 20 minutes

### Get Test Call ID:

1. Make a test call (or use existing) in Attention
2. Go to Attention dashboard
3. Find a call and copy its ID

### Run Test:

1. In n8n, open "Fetch Attention Transcript" workflow
2. Click **Test Workflow**
3. In the trigger node, add:
   ```json
   {
     "call_id": "YOUR-CALL-ID-FROM-ATTENTION"
   }
   ```
4. Click **Execute Workflow**
5. Watch each node execute

### Verify:

Check in Supabase:

```sql
SELECT id, title, source, created_at 
FROM transcripts_raw 
ORDER BY created_at DESC 
LIMIT 5;
```

✅ Should see your test call

---

## Step 3.4: Import Processing Workflows

**Time**: 30 minutes

Now import and configure the processing workflows:

### Import These (in order):

1. **Team Manager** (`⚙️ Team Manager.json`)
2. **CRM Manager** (`☁️ CRM Manager.json`)
3. **Transcript Processor** (`✂️ Transcript Processor.json`)
4. **Transcript Summarizer** (`🔖 Transcript Summarizer.json`)
5. **RAG Pipeline** (`🧮 RAG Pipeline.json`)
6. **Search Summaries Tool** (`🛠️ Search Summaries Tool.json`)
7. **Sales Agents** (`🤖 Sales Agents.json`)

### For Each Workflow:

1. Import from file
2. Update ALL credentials to your credentials
3. **Important**: Update model names:
   - Change `gpt-4.1` → `gpt-5.1`
   - Change `gpt-4.1-mini` → `gpt-4o-mini`
   - Add Gemini 3 Pro where applicable
4. Save
5. Test (if possible)

---

## Step 3.5: Test Full Pipeline

**Time**: 30 minutes

Let's process one transcript end-to-end:

### Step-by-Step:

1. **Fetch**: Already done in Step 3.3
2. **Process**: 
   ```
   - Open "Transcript Processor" workflow
   - Execute with: { "meeting_id": "YOUR-RAW-TRANSCRIPT-ID" }
   - Wait for completion
   ```

3. **Summarize**:
   ```
   - Open "Transcript Summarizer"
   - Execute with: { "transcript_id": "YOUR-PROCESSED-ID" }
   - Wait (this takes 2-3 minutes)
   ```

4. **Vectorize**:
   ```
   - Open "RAG Pipeline"
   - Execute with: { "transcript_id": "YOUR-PROCESSED-ID" }
   - Wait (this takes 1-2 minutes)
   ```

### Verify Full Pipeline:

```sql
-- Check all stages
SELECT 
  'Raw' as stage, COUNT(*) as count FROM transcripts_raw
UNION ALL
SELECT 
  'Processed', COUNT(*) FROM transcripts_processed
UNION ALL
SELECT 
  'Vectorized', COUNT(*) FROM transcripts_vectorized;
```

✅ Should see counts for each stage

---

## 📝 Phase 3 Complete! Checkpoint:

You should now have:
- ✅ All n8n workflows imported
- ✅ Credentials configured
- ✅ Attention fetch workflow created
- ✅ One transcript processed successfully
- ✅ Vector search data created
- ✅ Ready for frontend!

---

# 🟣 PHASE 4: Build Frontend (Day 8-12)

## Step 4.1: Initialize React Project

**Time**: 15 minutes

### Create Project:

```bash
# Navigate to your project folder
cd "/Users/matiashonorato/Desktop/Sales Agent Analyzer"

# Create frontend directory
mkdir frontend
cd frontend

# Initialize with Vite
npm create vite@latest . -- --template react-ts

# Install dependencies from frontend-package.json
npm install
```

### Install Additional Dependencies:

```bash
# Core dependencies
npm install @tanstack/react-query @tanstack/react-router zustand
npm install @supabase/supabase-js zod react-hook-form @hookform/resolvers
npm install date-fns recharts lucide-react

# UI components
npm install class-variance-authority clsx tailwind-merge
npm install sonner react-markdown remark-gfm

# Radix UI components
npm install @radix-ui/react-dialog @radix-ui/react-dropdown-menu
npm install @radix-ui/react-select @radix-ui/react-slot
npm install @radix-ui/react-tabs @radix-ui/react-toast @radix-ui/react-tooltip

# Dev dependencies
npm install -D tailwindcss postcss autoprefixer
npm install -D @types/react @types/react-dom
```

### Initialize Tailwind:

```bash
npx tailwindcss init -p
```

---

## Step 4.2: Configure shadcn/ui

**Time**: 10 minutes

```bash
npx shadcn-ui@latest init
```

Answer prompts:
- Style: **Default**
- Base color: **Slate**
- CSS variables: **Yes**

### Install Core Components:

```bash
npx shadcn-ui@latest add button
npx shadcn-ui@latest add card
npx shadcn-ui@latest add input
npx shadcn-ui@latest add table
npx shadcn-ui@latest add dialog
npx shadcn-ui@latest add dropdown-menu
npx shadcn-ui@latest add tabs
npx shadcn-ui@latest add toast
```

---

## Step 4.3: Set Up Supabase Client

**Time**: 10 minutes

Create: `src/lib/supabase.ts`

```typescript
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Database types (we'll expand this)
export type Database = {
  public: {
    Tables: {
      transcripts_processed: {
        Row: {
          id: string
          title: string
          date: string
          type: string | null
          // Add more fields as needed
        }
      }
    }
  }
}
```

Create `.env.local`:

```bash
VITE_SUPABASE_URL=https://xxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...
```

---

## Step 4.4: Build Authentication

**Time**: 30 minutes

I'll provide code in the next step. For now, create the structure:

```bash
mkdir -p src/app/auth
mkdir -p src/components/auth
mkdir -p src/hooks
mkdir -p src/stores
```

---

## 📊 Where We Are:

**Completed**:
- ✅ Phase 1: Database (100%)
- ✅ Phase 2: API Keys & n8n (100%)
- ✅ Phase 3: Workflows (100%)
- 🔄 Phase 4: Frontend (25% - project initialized)

**Next Steps**:
- [ ] Continue building frontend components
- [ ] Set up authentication
- [ ] Build dashboard
- [ ] Create agent chat interface

---

## ⏸️ Pause Point

We've made excellent progress! You now have:

1. ✅ **Database**: Fully set up with schema
2. ✅ **API Keys**: All services connected
3. ✅ **n8n**: Workflows importing and processing
4. ✅ **Test**: One transcript processed successfully
5. 🔄 **Frontend**: Project initialized, ready to build

---

## 🎯 What Do You Want to Do Next?

**Option A**: Continue with frontend (I'll provide all the code)
**Option B**: Test more transcripts through the pipeline first
**Option C**: Set up the agent chat workflow
**Option D**: Something specific you want to tackle?

Let me know which direction you'd like to go, and I'll provide the next detailed steps!


