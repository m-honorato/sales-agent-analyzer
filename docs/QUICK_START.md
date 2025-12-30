# ⚡ Quick Start - Get Running in 1 Hour

Want to see results fast? Follow this streamlined path.

---

## 🎯 Goal: Process Your First Transcript in 60 Minutes

This quick start gets you from **zero to working demo** as fast as possible.

---

## ⏱️ Step 1: Database (15 minutes)

```bash
# 1. Go to https://supabase.com
# 2. Create account + new project
# 3. Copy the supabase-schema.sql contents
# 4. Paste in SQL Editor → Run
# 5. Done!
```

**Save these**:
```
Project URL: ___________________
Anon Key: ___________________
```

---

## ⏱️ Step 2: API Keys (15 minutes)

Get the minimum required keys:

### OpenAI (for GPT-5.1)
- https://platform.openai.com/api-keys
- Create key → Copy
- Add $10 credit

### Google AI (for Gemini 3 Pro)
- https://ai.google.dev/gemini-api
- Get API key → Copy

### Anthropic (for Claude)
- https://console.anthropic.com
- Create key → Copy
- Add $10 credit

**Save**:
```
OPENAI_API_KEY=sk-proj-...
GOOGLE_AI_API_KEY=AIza...
ANTHROPIC_API_KEY=sk-ant-...
```

---

## ⏱️ Step 3: n8n Quick Setup (10 minutes)

### Fastest: Use n8n Cloud

```bash
# 1. Go to https://n8n.io/cloud
# 2. Start free trial
# 3. Create workspace
# 4. Done!
```

Add credentials:
1. Settings → Credentials
2. Add "Supabase API" (paste URL + key)
3. Add "OpenAI" (paste key)
4. Add "Anthropic" (paste key)

---

## ⏱️ Step 4: Test Workflow (20 minutes)

### Import and Test

1. **Import** "Transcript Summarizer" workflow
2. **Update** credentials in each node
3. **Change** model from `gpt-4.1` to `gpt-5.1`
4. **Manually execute** with sample data:

```json
{
  "title": "Test Call",
  "date": "2025-12-02T10:00:00Z",
  "segments": [
    {
      "speaker_id": 0,
      "text": "Tell me about your pricing",
      "start_time": "00:00:05"
    },
    {
      "speaker_id": 1,
      "text": "Our pricing starts at $99 per month",
      "start_time": "00:00:10"
    }
  ],
  "speakers": [
    {"id": 0, "first_name": "John", "last_name": "Doe", "role": "Prospect"},
    {"id": 1, "first_name": "Sarah", "last_name": "Smith", "role": "Seller"}
  ]
}
```

5. **Check Supabase** - should see processed transcript!

---

## ✅ Success Criteria

After 1 hour, you should have:

- ✅ Database with tables
- ✅ API keys configured
- ✅ n8n running
- ✅ One workflow tested
- ✅ Data in Supabase

---

## 🎯 What's Next?

Now that you have the basics working:

1. **Import more workflows** (30 min)
2. **Set up Attention.tech** (15 min)
3. **Process real call** (10 min)
4. **Build simple frontend** (2-3 hours)

---

## 🆘 Troubleshooting

**Database schema failed?**
- Make sure you copied the ENTIRE file
- Check for SQL syntax errors
- Try running in smaller sections

**API keys not working?**
- Verify you copied the full key
- Check for trailing spaces
- Ensure billing is set up

**n8n workflow errors?**
- Update ALL credentials in every node
- Change model names to latest versions
- Check API quotas

---

## 📞 Need Help?

- **Detailed Guide**: See `STEP_BY_STEP_GUIDE.md`
- **Full Docs**: See `IMPLEMENTATION_CHECKLIST.md`
- **Troubleshooting**: See each guide's troubleshooting section

---

**You're on your way! 🚀**

After this quick start, follow the full `STEP_BY_STEP_GUIDE.md` for the complete implementation.


