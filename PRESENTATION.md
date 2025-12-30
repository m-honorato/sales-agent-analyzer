# 🎯 Sales Intelligence Agent
## PM/PMM AI Workflow Fest - 6 Minute Presentation

---

## ⏱️ Timing Breakdown
| Section | Time | Slides |
|---------|------|--------|
| 1. Intro | 30 sec | 1 |
| 2. The Problem | 1 min | 2-3 |
| 3. The Insight | 1 min | 4-5 |
| 4. Solution for PMMs/PMs | 2 min | 6-8 |
| 5. Tech Stack | 1 min | 9 |
| 6. Outro + Contact | 30 sec | 10 |

---

## 📝 Presentation Script

---

### 🎬 SLIDE 1: INTRO (30 seconds)

**Title:** "What if every sales call could teach you something?"

**Script:**
> "Hi everyone, I'm Matias Honorato. I'm going to show you how I built a Sales Intelligence Agent that turns hours of sales call recordings into instant, actionable insights for Product Managers and Product Marketing teams.
>
> In the next 6 minutes, I'll share the problem I was trying to solve, the unexpected insight that led to this solution, and how you can build something similar yourself."

---

### 🔥 SLIDE 2-3: THE PROBLEM (1 minute)

**Title:** "The Hidden Gold Mine Nobody's Mining"

**Key Points:**
- Sales teams have **hundreds of hours** of call recordings
- PMMs need customer objection insights, but transcripts are buried
- PMs need friction point data, but reviewing calls takes forever
- Enterprise tools like Gong/Chorus cost **$1,200+/month per team**

**Script:**
> "Here's the problem: Your sales team is generating incredible customer intelligence every single day. Every objection, every pricing concern, every competitive mention - it's all there in recorded calls.
>
> But for most PM and PMM teams, this data is completely inaccessible. You'd need to listen to hours of recordings or beg sales for anecdotal feedback.
>
> And enterprise tools that solve this? Gong, Chorus - they start at over a thousand dollars per seat, per month. Most teams simply can't afford that."

---

### 💡 SLIDE 4-5: THE INSIGHT (1 minute)

**Title:** "The Go-To-Market Engineer"

**Quote from Jean Grosser (COO, Vercel):**
> "We take all of our call transcripts and run them through an agent. Our biggest loss that quarter, according to the account executive, was lost on price. But when you ran the agent over every interaction, it said: 'Actually, you lost because you never really got in touch with the economic buyer.'"

**Key Insight:**
- AI can see patterns humans miss
- The "lost bot" → "deal bot" evolution at Vercel
- One GTM engineer built it in **6 weeks, 30% of their time**
- Cost: **~$1,000/year** vs. millions in tooling

**Script:**
> "The breakthrough came from a podcast episode with Jean Grosser, the COO at Vercel.
>
> She described something called a 'go-to-market engineer' - someone who takes sales workflows and turns them into AI agents.
>
> Here's what blew my mind: Their team analyzed a lost deal. The sales rep said 'we lost on price.' But when they ran an AI agent across every call, email, and Slack message, the agent said: 'Actually, you lost because you never connected with the economic buyer.'
>
> The AI saw something the humans missed. And it cost them about a thousand dollars a year to run - not a thousand dollars per seat."

---

### 🎯 SLIDE 6-8: HOW THIS SOLVES REAL PAIN POINTS (2 minutes)

**Title:** "Intelligence for PMMs & PMs"

**For Product Marketing Managers:**

| Pain Point | Solution |
|------------|----------|
| "What objections are prospects raising?" | Ask the agent → instant analysis across all calls |
| "How do we compare to competitors?" | Agent identifies every competitive mention |
| "What messaging is resonating?" | Sentiment analysis by pitch type |
| "What's our positioning gap?" | Pattern detection across lost deals |

**For Product Managers:**

| Pain Point | Solution |
|------------|----------|
| "Where is onboarding friction?" | Agent highlights pain points in calls |
| "What features are customers asking for?" | Natural language query across transcripts |
| "Why are users churning?" | Analyze cancellation/support calls |
| "What do users love?" | Extract positive sentiment patterns |

**Live Demo Script:**
> "Let me show you. I'm going to ask: 'What objections did prospects raise in the TechStart call?'
>
> Within seconds, the agent analyzed the transcript and returned structured insights:
> - Onboarding friction: Password reset issues
> - Trust concerns: Bank account requirements felt premature  
> - Complexity objection: ICHRA too complex for a 12-person company
> - Timeline pressure: Needed to decide by Friday
>
> Each insight includes the exact quote from the conversation. 
>
> For a PMM, this is gold. You now have real customer voice data for your objection handling guide, your FAQ page, your sales enablement content.
>
> For a PM, you've just identified five friction points in your onboarding flow that you can prioritize in your next sprint."

---

### 🛠️ SLIDE 9: TECH STACK (1 minute)

**Title:** "Built in a Weekend, Runs for Pennies"

```
┌─────────────────┐
│  Call Source    │  Attention.tech, Fireflies, or manual upload
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  n8n Workflows  │  Orchestration (self-hosted, free)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Supabase      │  Postgres + pgvector (free tier)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   OpenAI API    │  Embeddings + GPT-4o (~$0.02/query)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  React Frontend │  Chat interface (Vercel, free)
└─────────────────┘
```

**Cost Breakdown:**
| Component | Monthly Cost |
|-----------|--------------|
| Supabase | $0 (free tier) |
| n8n (self-hosted) | $0 |
| OpenAI (1000 queries) | ~$20 |
| Vercel hosting | $0 |
| **Total** | **~$20/month** |

**Script:**
> "Here's the best part - you can build this yourself.
>
> The stack is entirely open source or free tier:
> - **n8n** for workflow orchestration - runs in Docker, completely free
> - **Supabase** for the database with vector search - free tier is generous
> - **OpenAI** for embeddings and chat - about 2 cents per query
> - **React frontend** hosted on Vercel - free
>
> Total cost? About $20 a month for a small team. Compare that to enterprise tools charging thousands.
>
> I built the first version in a weekend. The workflows are open source - you can import them and customize for your own use case."

---

### 🚀 SLIDE 10: OUTRO + CONTACT (30 seconds)

**Title:** "Start Mining Your Own Gold"

**Key Takeaways:**
1. 🎯 Sales calls contain invaluable PMM/PM intelligence
2. 🤖 AI agents can surface insights humans miss
3. 💰 You don't need enterprise budgets to build this
4. ⚡ Go-to-market engineering is the future

**Call to Action:**
> "The insight from Jean Grosser was that AI doesn't just automate tasks - it sees patterns we can't. Every sales call is data. Every objection is a positioning opportunity. Every friction point is a product improvement.
>
> You don't need to be an engineer to start. You don't need an enterprise budget. You just need to start treating your sales calls as a gold mine worth mining.
>
> If you want to chat more about building AI workflows for go-to-market, find me on LinkedIn."

---

## 📍 Where to Find Me

**LinkedIn:** [Matias Honorato](https://linkedin.com/in/matiashonorato)

---

## 🎤 Speaker Notes

### Tips for Delivery:
1. **Energy** - Start with enthusiasm, this is exciting!
2. **Demo** - If possible, show a live query to the agent
3. **Pause on insights** - Let the Jean Grosser quote land
4. **Cost comparison** - The $20 vs $1,200 is your mic drop moment
5. **End with empowerment** - They can build this too

### If Running Short on Time:
- Cut the detailed PM pain points table
- Summarize tech stack verbally without going into each component

### If Running Long:
- Extend the demo section with follow-up questions
- Add Q&A

---

## 📊 Optional Slides

### Backup: Architecture Diagram
```
User Question → n8n Webhook → OpenAI Embedding → 
Supabase Vector Search → Context Retrieval → 
GPT-4o Analysis → Formatted Response → Frontend
```

### Backup: Sample Questions to Demo
- "What concerns did customers have about pricing?"
- "Which calls mentioned competitors?"
- "What friction points came up in onboarding calls?"
- "Summarize the key themes from last week's calls"

---

*Last updated: December 2024*

