# 🐳 Deploy to Self-Hosted n8n (Docker)

## 🎯 Goal: Import workflows into your Docker n8n instance

**Time**: 20-30 minutes
**Difficulty**: Easy

---

## ✅ Prerequisites

You mentioned you have n8n running in Docker already. Let's verify:

### Check if n8n is Running

```bash
# Check running containers
docker ps | grep n8n

# Should show something like:
# CONTAINER ID   IMAGE            STATUS
# abc123def456   n8nio/n8n:latest Up 2 hours   0.0.0.0:5678->5678/tcp
```

If not running, start it:

```bash
# Start n8n container
docker start n8n

# Or if you need to create it:
docker run -d --restart unless-stopped \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n:latest
```

### Access n8n Web Interface

```bash
# Open in browser:
http://localhost:5678

# Or if on remote server:
http://YOUR-SERVER-IP:5678
```

---

## 🔐 Step 1: Add Credentials (10 min)

### In n8n Web UI:

1. **Go to**: Settings (gear icon, bottom left)
2. **Click**: Credentials
3. **Add** each credential below:

### A. Supabase API

```
Click: "Add Credential"
Search: "Supabase"
Select: "Supabase API"

Fill in:
  Name: Supabase (Sales Intelligence)
  Host: https://your-project.supabase.co
  Service Role Secret: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... 
                       (the service_role key you found)

Click: "Test" → Should show "Connected successfully"
Click: "Save"
```

### B. OpenAI API

```
Click: "Add Credential"
Search: "OpenAI"
Select: "OpenAI API"

Fill in:
  Name: OpenAI (GPT-5.1)
  API Key: sk-proj-your-key-here

Click: "Save"
```

### C. Anthropic API

```
Click: "Add Credential"
Search: "Anthropic"
Select: "Anthropic API"

Fill in:
  Name: Anthropic (Claude)
  API Key: sk-ant-your-key-here

Click: "Save"
```

### D. Google AI (Gemini)

**Note**: n8n might not have a built-in Google AI credential yet. We'll use HTTP Request with header auth:

```
Click: "Add Credential"
Search: "Header Auth"
Select: "Header Auth"

Fill in:
  Name: Google AI (Gemini)
  Name: x-goog-api-key
  Value: AIzaSy-your-key-here

Click: "Save"
```

### E. Cohere API (for reranking)

```
Click: "Add Credential"
Search: "Cohere"
Select: "Cohere API"

Fill in:
  Name: Cohere Reranking
  API Key: your-cohere-key

Click: "Save"
```

---

## 📥 Step 2: Import Workflow (5 min)

### Method 1: Via Web UI (Easiest)

1. **In n8n**: Click **Workflows** (top left)
2. **Click**: The "+" button or "Add Workflow"
3. **Click**: The three dots menu (⋮) → "Import from File"
4. **Select**: `Quick-Test-Workflow.json` from your folder
5. **Workflow opens!**

### Method 2: Via File System (Alternative)

If you have terminal access to the Docker host:

```bash
# Copy workflow JSON to n8n data directory
cp "/Users/matiashonorato/Desktop/Sales Agent Analyzer/Quick-Test-Workflow.json" \
   ~/.n8n/workflows/

# Or if custom mount point:
docker cp "Quick-Test-Workflow.json" n8n:/home/node/.n8n/workflows/

# Restart n8n
docker restart n8n

# Wait 10 seconds, then refresh browser
```

---

## 🔧 Step 3: Configure Workflow (5 min)

### Update Team ID

The workflow has a placeholder. Let's fix it:

1. **In the workflow**: Click the **"Save to Supabase"** node (last node)
2. **Find**: `team_id` field
3. **Replace**: `YOUR-TEAM-ID-HERE` with your actual team ID

**To get your team ID**, run in Supabase SQL Editor:

```sql
SELECT id, name, slug FROM teams;
```

Copy the UUID and paste it into the workflow.

4. **Update Credentials**: Click each node, select your credentials from dropdowns

### Verify All Nodes Have Credentials:

- ✅ "GPT-5.1 Analysis" → Select `OpenAI (GPT-5.1)`
- ✅ "Save to Supabase" → Select `Supabase (Sales Intelligence)`

5. **Save workflow** (top right)

---

## 🚀 Step 4: Execute Test (5 min)

### Run the Workflow:

1. **Click**: "Test workflow" button (top right)
2. **Click**: "Execute Workflow" 
3. **Watch**: Each node execute in sequence

### What You'll See:

```
Node 1: Start Here              ✅ Green
  ↓
Node 2: Create Test Transcript  ✅ Green (generates sample data)
  ↓
Node 3: Format for AI           ✅ Green (formats transcript)
  ↓
Node 4: GPT-5.1 Analysis        ✅ Green (AI analyzes - takes 5-10 sec)
  ↓
Node 5: Save to Supabase        ✅ Green (stores result)
```

**All nodes should turn green!** ✨

### View Output:

1. **Click** on "GPT-5.1 Analysis" node
2. **See** the AI-generated analysis in the output panel
3. **Click** on "Save to Supabase" node
4. **See** the database insert confirmation

---

## 🔍 Step 5: Verify in Database (2 min)

### Check Supabase:

```sql
-- Run in Supabase SQL Editor
SELECT 
  id,
  title,
  type,
  created_at,
  custom_summaries->'gpt5_analysis' as ai_summary,
  jsonb_pretty(speakers) as speakers
FROM transcripts_processed
ORDER BY created_at DESC
LIMIT 1;
```

**You should see**:
- ✅ Title: "Test Discovery Call - Pricing Discussion"
- ✅ Type: "Prospect discovery"
- ✅ AI Summary: GPT-5.1's analysis
- ✅ Speakers: John and Sarah

---

## 🎉 SUCCESS!

If you see the data in Supabase, **you've successfully**:

- ✅ Connected Docker n8n to Supabase
- ✅ Used GPT-5.1 to analyze a transcript
- ✅ Stored results in your database
- ✅ Proven the entire pipeline works!

---

## 🐳 Docker-Specific Tips

### View n8n Logs

```bash
# See real-time logs
docker logs -f n8n

# Last 100 lines
docker logs --tail 100 n8n
```

### Restart n8n

```bash
docker restart n8n
```

### Access n8n Files

```bash
# Your n8n data is in:
~/.n8n/

# Workflows are stored in:
~/.n8n/workflows/

# List workflows:
ls -la ~/.n8n/workflows/
```

### Backup Workflows

```bash
# Backup all workflows
cp -r ~/.n8n/workflows ~/n8n-workflows-backup-$(date +%Y%m%d)

# Or export from UI:
# Each workflow → Settings → Export
```

### Update n8n Version

```bash
# Pull latest image
docker pull n8nio/n8n:latest

# Stop current container
docker stop n8n

# Remove old container
docker rm n8n

# Start with new version
docker run -d --restart unless-stopped \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n:latest
```

---

## 📥 Import More Workflows

Once the test workflow succeeds, import the full workflows:

### Import Order (Recommended):

1. **`✍🏻 Log Handler.json`** (simple, no dependencies)
2. **`⚙️ Team Manager.json`** (user management)
3. **`☁️ CRM Manager.json`** (contact management)
4. **`✂️ Transcript Processor.json`** (core processing)
5. **`🔖 Transcript Summarizer.json`** (AI summaries)
6. **`🧮 RAG Pipeline.json`** (vectorization)
7. **`🛠️ Search Summaries Tool.json`** (search tool)
8. **`🤖 Sales Agents.json`** (agent chat)
9. **`🧸 Orchestrator.json`** (main coordinator - import last)

### For Each Workflow:

```bash
# In n8n UI:
1. Workflows → "+" → Import from File
2. Select the JSON file
3. Update ALL credentials in every node
4. Update model names:
   - gpt-4.1 → gpt-5.1
   - gpt-4.1-mini → gpt-4o-mini
5. Replace team_id placeholders
6. Save
7. Test (if standalone workflow)
```

---

## 🔄 Environment Variables (Optional)

If you want to use environment variables in Docker:

### Create `.env` file:

```bash
# Create in same directory as docker run command
cat > n8n.env << 'EOF'
N8N_ENCRYPTION_KEY=your-random-key-here
WEBHOOK_URL=http://localhost:5678/
OPENAI_API_KEY=sk-proj-...
ANTHROPIC_API_KEY=sk-ant-...
GOOGLE_AI_API_KEY=AIza...
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_KEY=eyJ...
EOF
```

### Run n8n with env file:

```bash
docker run -d --restart unless-stopped \
  --name n8n \
  -p 5678:5678 \
  --env-file n8n.env \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n:latest
```

Then in workflows, use: `{{ $env.OPENAI_API_KEY }}`

---

## 🌐 Accessing n8n Remotely

### If n8n is on a Server:

```bash
# Option 1: SSH Tunnel (Secure)
ssh -L 5678:localhost:5678 user@your-server

# Then access: http://localhost:5678

# Option 2: Expose with Basic Auth
docker run -d --restart unless-stopped \
  --name n8n \
  -p 5678:5678 \
  -e N8N_BASIC_AUTH_ACTIVE=true \
  -e N8N_BASIC_AUTH_USER=admin \
  -e N8N_BASIC_AUTH_PASSWORD=your-strong-password \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n:latest

# Access: http://your-server-ip:5678
```

### Option 3: Use Cloudflare Tunnel (Free, Secure)

```bash
# Install cloudflared
brew install cloudflare/cloudflare/cloudflared

# Create tunnel
cloudflared tunnel --url http://localhost:5678

# You get: https://random-name.trycloudflare.com
```

---

## ✅ Quick Verification Checklist

Before importing workflows, verify:

- [ ] n8n accessible at http://localhost:5678
- [ ] Can log in to n8n
- [ ] Supabase credential added and tested
- [ ] OpenAI credential added
- [ ] Anthropic credential added (if doing Step 5)
- [ ] Have your team ID ready

---

## 🚀 Ready to Import?

Now that you know where the service_role key is:

1. **Copy** the service_role key from Supabase
2. **Add** Supabase credential in n8n (as shown above)
3. **Import** `Quick-Test-Workflow.json`
4. **Update** team_id in the workflow
5. **Execute** and watch it work!

---

## 🐛 Troubleshooting Docker n8n

### Can't access http://localhost:5678?

```bash
# Check if n8n is running
docker ps | grep n8n

# If not running, start it:
docker start n8n

# Check logs for errors:
docker logs n8n --tail 50
```

### Port already in use?

```bash
# Use different port
docker run -d --name n8n \
  -p 5679:5678 \  # Changed to 5679
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n:latest

# Access: http://localhost:5679
```

### Workflow import not working?

```bash
# Copy file directly to n8n data folder
cp "Quick-Test-Workflow.json" ~/.n8n/workflows/

# Restart n8n
docker restart n8n

# Refresh browser
```

### Credential test fails?

```bash
# Check n8n can reach internet
docker exec n8n ping -c 3 google.com

# Check if Supabase URL is correct
docker exec n8n curl https://your-project.supabase.co

# View detailed logs
docker logs n8n -f
```

---

## 💡 Docker n8n Advantages

✅ **Free** - No monthly n8n cloud costs
✅ **Control** - Full access to data and configs
✅ **Privacy** - Workflows stay on your infrastructure
✅ **Customizable** - Can add custom nodes
✅ **Fast** - Local execution, no network latency

---

## 📋 Your Credentials Summary

For n8n Docker, you'll need to add:

| Credential | Type | Where to Get |
|------------|------|--------------|
| **Supabase** | Supabase API | Supabase → Settings → API → service_role |
| **OpenAI** | OpenAI API | ✅ You have this |
| **Anthropic** | Anthropic API | console.anthropic.com → API Keys |
| **Google AI** | Header Auth | ai.google.dev → Get API Key |
| **Cohere** | Cohere API | dashboard.cohere.com → API Keys |

---

## 🎯 Next Action

**Right now**: 

1. Find and copy your **service_role** key from Supabase (scroll down in that screenshot area)
2. Access your n8n at http://localhost:5678
3. Add the Supabase credential
4. Import the Quick-Test-Workflow.json

**Let me know when you**:
- ✅ Found the service_role key
- ✅ Can access n8n in browser
- ✅ Ready to add credentials

And I'll guide you through the import! 🚀


