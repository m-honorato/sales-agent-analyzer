# 🤖 Sales Intelligence Agent

> Democratizing sales insights without expensive tools like Attention.tech or Gong

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.3-blue)](https://www.typescriptlang.org/)
[![React](https://img.shields.io/badge/React-19-61dafb)](https://react.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-Vector%20DB-green)](https://supabase.com/)

## 🌟 What is This?

A comprehensive sales intelligence platform that:
- 📞 **Ingests** sales call recordings from Attention.tech (or Fireflies)
- 🧠 **Processes** transcripts with AI (GPT-4o, Claude Sonnet 4.5, Gemini)
- 📊 **Analyzes** conversations for objections, pricing, competition, performance
- 🔍 **Surfaces insights** via natural language queries (RAG-powered chat)
- 📈 **Tracks metrics** like sentiment, deal velocity, rep performance

Built for teams who can't afford enterprise solutions like Gong or Chorus.ai.

---

## 🏗️ Architecture

```
┌─────────────┐
│  Attention  │  ← Sales call recordings
│   API       │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│     n8n     │  ← Workflow orchestration
│  Workflows  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Supabase   │  ← PostgreSQL + Vector DB
│  (Postgres) │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ React + API │  ← Modern web interface
│  Frontend   │
└─────────────┘
```

### Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | React 19 + Vite + TypeScript |
| **UI** | shadcn/ui + Tailwind CSS |
| **State** | Zustand + TanStack Query |
| **Backend** | Supabase (Postgres + Auth + Edge Functions) |
| **Workflows** | n8n (self-hosted or cloud) |
| **AI Models** | GPT-4o, Claude Sonnet 4.5, Gemini 2.0 Flash |
| **Embeddings** | OpenAI text-embedding-3-large |
| **Vector DB** | Supabase pgvector |
| **Caching** | Upstash Redis |
| **Monitoring** | Sentry + PostHog |

---

## 🚀 Quick Start

### Prerequisites

- Node.js 20+ (or Bun 1.0+)
- Supabase account
- n8n instance (cloud or self-hosted)
- API keys: OpenAI, Anthropic, Attention.tech

### 1. Clone & Install

```bash
git clone <your-repo>
cd sales-intelligence-agent

# Install dependencies (choose one)
npm install
# or
bun install
```

### 2. Set Up Supabase

```bash
# Create a new Supabase project at https://supabase.com

# Run the schema
psql -h your-db-host -U postgres -d postgres -f supabase-schema.sql

# Or use Supabase CLI
supabase db reset
```

### 3. Configure Environment

```bash
cp .env.example .env

# Edit .env with your credentials
nano .env
```

### 4. Import n8n Workflows

1. Log into your n8n instance
2. Import each `.json` file from the root directory:
   - `🧸 Orchestrator.json`
   - `🪲 Fetch Fireflies Transcript.json`
   - etc.
3. Update credentials in each workflow

### 5. Run the Application

```bash
# Development
npm run dev

# Production build
npm run build
npm run preview
```

Visit `http://localhost:5173`

---

## 📖 Documentation

### Project Structure

```
sales-intelligence-agent/
├── frontend/                  # React application
│   ├── src/
│   │   ├── app/              # Pages/routes
│   │   ├── components/       # React components
│   │   ├── lib/              # Utilities
│   │   ├── hooks/            # Custom hooks
│   │   └── stores/           # Zustand stores
│   └── package.json
│
├── n8n-workflows/            # n8n JSON exports
│   ├── orchestrator.json
│   ├── fetch-transcript.json
│   └── ...
│
├── supabase/
│   ├── migrations/           # Database migrations
│   └── functions/            # Edge functions
│
├── docs/                     # Documentation
│   ├── API.md
│   ├── WORKFLOWS.md
│   └── DEPLOYMENT.md
│
├── supabase-schema.sql       # Complete DB schema
├── MODERNIZATION_PLAN.md     # Improvement roadmap
└── README.md
```

### Key Workflows

#### 1. 🧸 Orchestrator
**Purpose**: Main pipeline coordinator

**Triggers**:
- Daily at 1AM (fetch new calls)
- Daily at 3AM (process transcripts)
- Daily at 5AM (summarize)
- Daily at 7AM (vectorize)

**Flow**:
```
Fetch calls → Process speakers → Summarize → Create embeddings → Store in vector DB
```

#### 2. 🤖 Sales Agents
**Purpose**: Answer user queries using RAG

**Tools**:
- `search_summaries` - High-level insights
- `search_segments` - Detailed dialogue search
- `search_transcripts` - Metadata queries

**Example queries**:
- "Which customers mentioned pricing objections this month?"
- "Show me calls where competitors were discussed"
- "What are the top objections from prospects?"

---

## 🔧 Configuration

### Supabase Setup

1. **Enable Vector Extension**
```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

2. **Create Functions** (see `supabase-schema.sql`)

3. **Set Up RLS Policies** (already in schema)

4. **Configure Auth**
   - Enable Email/Password
   - Add OAuth providers (optional)

### n8n Credentials

Each workflow needs these credentials:

1. **Supabase API**
   - URL: `https://your-project.supabase.co`
   - Key: Service role key

2. **OpenAI API**
   - API Key: `sk-...`

3. **Anthropic API**
   - API Key: `sk-ant-...`

4. **Attention.tech API**
   - API Key: From your Attention dashboard
   - Webhook Secret: For real-time updates

### Environment Variables

See `.env.example` for all required variables.

**Critical ones**:
- `SUPABASE_URL` & `SUPABASE_ANON_KEY`
- `OPENAI_API_KEY`
- `ANTHROPIC_API_KEY`
- `ATTENTION_API_KEY`

---

## 🎯 Key Features

### 1. Automated Transcript Processing
- ✅ Fetch from Attention API
- ✅ Extract speakers & accounts
- ✅ Identify call type (discovery, demo, objections, etc.)
- ✅ Generate 9 different summary perspectives
- ✅ Calculate performance metrics (clarity, sentiment, velocity)

### 2. Intelligent Search
- ✅ Vector similarity search
- ✅ Metadata filtering (date, account, speaker, type)
- ✅ Reranking with Cohere
- ✅ Hybrid search (vector + keyword)

### 3. AI Agent Chat
- ✅ Natural language queries
- ✅ Multi-tool orchestration
- ✅ Context-aware responses
- ✅ Source citations
- ✅ Streaming responses (optional)

### 4. Analytics Dashboard
- ✅ Call volume trends
- ✅ Sentiment analysis
- ✅ Rep performance comparison
- ✅ Objection frequency
- ✅ Competitor mentions

---

## 🧪 Testing

```bash
# Run tests
npm test

# E2E tests
npm run test:e2e

# Type checking
npm run type-check
```

---

## 🚢 Deployment

### Frontend (Vercel)

```bash
# Connect your repo to Vercel
vercel

# Set environment variables in Vercel dashboard
# Deploy
vercel --prod
```

### n8n (Self-hosted)

```bash
# Docker Compose
docker-compose up -d

# Or Railway/Render one-click deploy
# See n8n documentation
```

### Supabase

Already hosted! Just ensure:
- ✅ Database is migrated
- ✅ RLS policies are enabled
- ✅ Edge functions deployed (if any)

---

## 💰 Cost Estimation

Based on 1000 calls/month:

| Service | Usage | Cost |
|---------|-------|------|
| **Supabase** | Database + Vector + Auth | ~$25/mo |
| **n8n** | Self-hosted (Railway) | ~$20/mo |
| **OpenAI** | GPT-4o + Embeddings | ~$80/mo |
| **Anthropic** | Claude Sonnet 4.5 | ~$40/mo |
| **Cohere** | Reranking | ~$10/mo |
| **Upstash Redis** | Free tier | $0 |
| **Vercel** | Hosting | $0 (free tier) |
| **Total** | | **~$175/mo** |

**vs. Gong/Chorus**: ~$1,200+/mo per team

---

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repo
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a PR

See `CONTRIBUTING.md` for details.

---

## 📝 License

MIT License - see `LICENSE` file

---

## 🙏 Acknowledgments

- Built by Matias Honorato
- Inspired by the need for accessible sales intelligence
- Powered by Supabase, n8n, OpenAI, Anthropic

---

## 📞 Support

- 📧 Email: your-email@example.com
- 💬 Discord: [Join our community](#)
- 📚 Docs: [Full documentation](./docs/)
- 🐛 Issues: [GitHub Issues](#)

---

## 🗺️ Roadmap

- [x] Core transcript processing
- [x] Vector search & RAG
- [x] AI agent chat
- [ ] Real-time call analysis
- [ ] Mobile app
- [ ] Slack/Teams integration
- [ ] Advanced coaching insights
- [ ] Predictive deal scoring

See `MODERNIZATION_PLAN.md` for detailed improvements.

---

**⭐ Star this repo if you find it useful!**

Last updated: December 2025







