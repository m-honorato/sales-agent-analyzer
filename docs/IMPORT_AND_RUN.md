# 🎯 Import Workflow & Run First Test

**Current Status**: n8n running, credentials added ✅
**Next**: Import workflow and process first transcript
**Time**: 10 minutes

---

## 📥 Step 1: Import the Quick Test Workflow (2 min)

### In n8n Interface:

1. **Click**: "Workflows" (top left corner)
2. **Click**: The **"+"** button or **"Add Workflow"**
3. **Click**: The three dots menu **⋮** (top right)
4. **Select**: "Import from File"
5. **Browse** to: `/Users/matiashonorato/Desktop/Sales Agent Analyzer/Quick-Test-Workflow.json`
6. **Click**: "Open"

**You should see**: A workflow with 5 connected nodes appearing on the canvas!

```
[Start Here] → [Create Test Transcript] → [Format for AI] → [GPT-5.1 Analysis] → [Save to Supabase]
```

---

## 🔧 Step 2: Get Your Team ID (2 min)

We need to replace the placeholder team_id in the workflow.

### In Supabase SQL Editor:

```sql
SELECT id, name, slug FROM teams;
```

**Copy the `id`** (the UUID, looks like: `550e8400-e29b-41d4-a716-446655440000`)

---

## ✏️ Step 3: Update Team ID in Workflow (2 min)

### In n8n:

1. **Click** on the last node: **"Save to Supabase"**
2. **Scroll down** in the node settings to find the field: `team_id`
3. **You'll see**: `YOUR-TEAM-ID-HERE`
4. **Click** on that field
5. **Replace** with your actual team ID (paste the UUID)
6. **Also update** in the "Create Test Transcript" node:
   - Click that node
   - Find the line: `team_id: 'YOUR-TEAM-ID-HERE',`
   - Replace with your UUID (keep the quotes)

---

## 🔐 Step 4: Assign Credentials (2 min)

Make sure each node has credentials assigned:

### Check These Nodes:

#### Node 4: "GPT-5.1 Analysis"
1. **Click** the node
2. **Find**: "Credential to connect with"
3. **Select**: `OpenAI (GPT-5.1)` (or whatever you named it)

#### Node 5: "Save to Supabase"  
1. **Click** the node
2. **Find**: "Credential to connect with"
3. **Select**: `Supabase (Sales Intelligence)` (or your name)

### Save the Workflow:

**Click**: "Save" button (top right)

---

## 🚀 Step 5: Execute! (2 min)

Time for the magic! ✨

### Run the Workflow:

1. **Click**: "Test workflow" button (top right, looks like a play button)
2. **Click**: "Execute Workflow"
3. **Watch**: The nodes light up one by one!

### Expected Flow:

```
⚪ Start Here                → ✅ Green (instant)
⚪ Create Test Transcript    → ✅ Green (instant)
⚪ Format for AI             → ✅ Green (instant)
⚪ GPT-5.1 Analysis          → ⏳ Yellow... → ✅ Green (5-10 seconds)
⚪ Save to Supabase          → ✅ Green (instant)
```

**Total time**: ~10-15 seconds

### View the Output:

1. **Click** on "GPT-5.1 Analysis" node
2. **Look** at the OUTPUT panel (bottom)
3. **You should see**: JSON with AI analysis of the test call!

Example output:
```json
{
  "summary": "Discovery call with Example Corp discussing pricing...",
  "objections": ["Pricing concerns", "Competitor comparison with Rippling"],
  "competitors_mentioned": ["Rippling"],
  "sentiment": "neutral",
  "deal_velocity_score": 0.6,
  "key_insights": [...]
}
```

---

## 🔍 Step 6: Verify in Database (2 min)

### Check Supabase:

Go to Supabase SQL Editor and run:

```sql
SELECT 
  id,
  title,
  type,
  date,
  jsonb_pretty(custom_summaries) as ai_analysis,
  jsonb_pretty(speakers) as speakers,
  created_at
FROM transcripts_processed
ORDER BY created_at DESC
LIMIT 1;
```

**You should see**:
- ✅ **title**: "Test Discovery Call - Pricing Discussion"
- ✅ **type**: "Prospect discovery"
- ✅ **ai_analysis**: The GPT-5.1 analysis
- ✅ **speakers**: John Prospect and Sarah Seller
- ✅ **created_at**: Just now!

---

## 🎉 SUCCESS CRITERIA

If all 5 nodes are green AND you see data in Supabase:

**🎊 CONGRATULATIONS! 🎊**

You've successfully:
- ✅ Set up Supabase database
- ✅ Configured n8n with latest AI models
- ✅ Processed a transcript with GPT-5.1
- ✅ Stored results in production database
- ✅ Proven the entire pipeline works!

---

## 🐛 Troubleshooting

### GPT-5.1 Node Fails (Red)

**Click the node → Look at error message**

Common issues:

**"Invalid API key"**:
```
- Go to Settings → Credentials
- Edit OpenAI credential
- Re-paste API key (check for spaces)
- Save and try again
```

**"Insufficient quota"**:
```
- Go to platform.openai.com
- Billing → Add credit
- Wait 2 minutes
- Try again
```

**"Model not found"**:
```
- Your API key might not have access to gpt-5.1
- Try changing model to: gpt-4o (also excellent)
- In the node, change: model: "gpt-4o"
```

### Supabase Node Fails (Red)

**Error: "Failed to connect"**:
```
- Check Supabase credential
- Verify Host URL (no trailing slash)
- Verify Service Role key is correct
- Test credential again
```

**Error: "Permission denied"**:
```sql
-- Make sure team exists
SELECT * FROM teams;

-- Check team_id matches
```

### No Data in Database?

```sql
-- Check if data exists
SELECT COUNT(*) FROM transcripts_processed;

-- Check recent inserts
SELECT created_at FROM transcripts_processed ORDER BY created_at DESC LIMIT 5;
```

---

## 🎯 What to Do Now

**If everything worked**:
1. Take a screenshot of the green nodes! 📸
2. Tell me: "Test workflow succeeded!"
3. I'll show you how to import the full workflows

**If something failed**:
1. Tell me which node turned red
2. Click on it and copy the error message
3. I'll help you fix it!

**Ready for next step?** Let me know your status! 🚀


