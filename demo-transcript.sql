-- =====================================================
-- DEMO TRANSCRIPT FOR PRESENTATION
-- Realistic onboarding call with objections & friction points
-- Perfect for PMM/PM research demo
-- =====================================================

-- Insert demo transcript into transcripts_processed
INSERT INTO transcripts_processed (
  id,
  title, 
  date, 
  duration_seconds, 
  type, 
  team_id,
  speakers, 
  segments, 
  is_valid, 
  is_summarized
) VALUES (
  gen_random_uuid(),
  'Beneflex and TechStart Solutions',
  '2025-12-17T14:30:00Z',
  1320, -- 22 minutes
  'Client onboarding',
  '00000000-0000-0000-0000-000000000001', -- Default team from schema
  
  -- Speakers
  $$[
    {
      "id": 0,
      "name": "Alex Martinez",
      "role": "Seller",
      "email": "alex@beneflex.io",
      "organization": "Beneflex"
    },
    {
      "id": 1,
      "name": "Jennifer Park",
      "role": "Prospect",
      "email": "jennifer@techstartsolutions.com",
      "organization": "TechStart Solutions"
    },
    {
      "id": 2,
      "name": "David Chen",
      "role": "Prospect",
      "email": "david@techstartsolutions.com",
      "organization": "TechStart Solutions"
    }
  ]$$::jsonb,
  
  -- Full conversation segments with objections & friction
  $$[
    {
      "index": 0,
      "speaker_name": "Alex Martinez",
      "text": "Hi Jennifer and David, thanks for making time today. I know you signed up last week and wanted to get you set up. How are you both doing?",
      "start_time": 0,
      "end_time": 8
    },
    {
      "index": 1,
      "speaker_name": "Jennifer Park",
      "text": "Hi Alex, doing okay. Honestly, a bit frustrated already. I tried logging into the platform yesterday and couldn't get past the password reset screen. The email never came through.",
      "start_time": 8,
      "end_time": 25
    },
    {
      "index": 2,
      "speaker_name": "Alex Martinez",
      "text": "Oh no, I'm so sorry about that. Let me help troubleshoot that right away. Sometimes our emails end up in spam. Did you check your spam folder?",
      "start_time": 25,
      "end_time": 38
    },
    {
      "index": 3,
      "speaker_name": "Jennifer Park",
      "text": "Yeah, I checked spam, promotions, everything. Nothing. And then I tried again this morning and still nothing. It's been 24 hours. I just want to see what plans are available for our team.",
      "start_time": 38,
      "end_time": 58
    },
    {
      "index": 4,
      "speaker_name": "Alex Martinez",
      "text": "I completely understand your frustration. Let me escalate this to our support team right after this call. But we can still move forward today - I can walk you through everything on my screen. Does that work?",
      "start_time": 58,
      "end_time": 75
    },
    {
      "index": 5,
      "speaker_name": "David Chen",
      "text": "That would be helpful, but honestly, why do we need to provide our bank account information before we can even see the plan options? That seems backwards to me.",
      "start_time": 75,
      "end_time": 92
    },
    {
      "index": 6,
      "speaker_name": "Alex Martinez",
      "text": "Great question, David. I hear that concern a lot. The bank account connection is actually for automated payments once you enroll, but you're right - you should be able to browse plans first. Let me show you how to access the plan comparison tool without entering payment info.",
      "start_time": 92,
      "end_time": 115
    },
    {
      "index": 7,
      "speaker_name": "Jennifer Park",
      "text": "Okay, but even if we can see the plans, how do we know which one to pick? There are like 15 different options and they all look the same to me. What's the difference between the Silver and Gold plans?",
      "start_time": 115,
      "end_time": 135
    },
    {
      "index": 8,
      "speaker_name": "Alex Martinez",
      "text": "Absolutely, let me break that down. The Silver plan has a $400 monthly allowance per employee, while Gold is $600. The main difference is the deductible - Silver has a $2,000 deductible, Gold is $1,000. For a team your size, I'd typically recommend starting with Silver unless you have employees with ongoing health needs.",
      "start_time": 135,
      "end_time": 160
    },
    {
      "index": 9,
      "speaker_name": "David Chen",
      "text": "Wait, so we're giving employees $400 a month, but they still have to pay a $2,000 deductible? That doesn't make sense. Why would they want that?",
      "start_time": 160,
      "end_time": 178
    },
    {
      "index": 10,
      "speaker_name": "Alex Martinez",
      "text": "I understand the confusion. The $400 allowance covers their monthly premium, and the deductible only applies if they have medical expenses. So they're getting their insurance premium covered, and the deductible is just for when they actually use healthcare services. Does that help clarify?",
      "start_time": 178,
      "end_time": 205
    },
    {
      "index": 11,
      "speaker_name": "Jennifer Park",
      "text": "Sort of, but honestly this is getting complicated. We're a small company - 12 employees. We don't have an HR person to explain all this. How are our employees supposed to understand ICHRA if we barely do?",
      "start_time": 205,
      "end_time": 228
    },
    {
      "index": 12,
      "speaker_name": "Alex Martinez",
      "text": "That's a really valid concern, Jennifer. We actually have resources for that - employee education materials, one-pagers, even short videos. But I hear you - the complexity is a real barrier. What if I set up a 30-minute employee onboarding session where I walk everyone through it?",
      "start_time": 228,
      "end_time": 252
    },
    {
      "index": 13,
      "speaker_name": "David Chen",
      "text": "That would help, but we need to make a decision by Friday because our current plan expires at the end of the month. Can we even get set up that fast?",
      "start_time": 252,
      "end_time": 270
    },
    {
      "index": 14,
      "speaker_name": "Alex Martinez",
      "text": "Yes, absolutely. If we can get your bank account connected today and you select plans by Wednesday, we can have you live by January 1st. The bank verification usually takes 1-2 business days, so timing is tight but doable.",
      "start_time": 270,
      "end_time": 295
    },
    {
      "index": 15,
      "speaker_name": "Jennifer Park",
      "text": "Okay, but back to the bank account thing - why do you need our business bank account? Can't we just pay by credit card like we do for everything else? I'm not comfortable giving bank access to a company I just met.",
      "start_time": 295,
      "end_time": 318
    },
    {
      "index": 16,
      "speaker_name": "Alex Martinez",
      "text": "I totally get the security concern. The bank account is required because ICHRA payments need to come from your business account for tax purposes - it's an IRS requirement, not ours. We use Plaid for bank connections, which is bank-level encryption. But I understand if that feels like a big ask upfront.",
      "start_time": 318,
      "end_time": 345
    },
    {
      "index": 17,
      "speaker_name": "David Chen",
      "text": "IRS requirement or not, it still feels like we're being asked to trust you with our bank account before we've even decided if this is right for us. What if we want to cancel? How hard is that?",
      "start_time": 345,
      "end_time": 365
    },
    {
      "index": 18,
      "speaker_name": "Alex Martinez",
      "text": "Fair question. You can cancel anytime - there's no long-term contract. If you cancel mid-year, you just need to give 30 days notice and we'll stop the automatic payments. But I'd love to understand - what would make you feel more comfortable moving forward?",
      "start_time": 365,
      "end_time": 388
    },
    {
      "index": 19,
      "speaker_name": "Jennifer Park",
      "text": "Honestly? If I could just see the plans and pricing without all these hoops, that would help. And maybe some testimonials or case studies from companies our size. We're not a Fortune 500 - we need to know this works for small businesses.",
      "start_time": 388,
      "end_time": 412
    },
    {
      "index": 20,
      "speaker_name": "Alex Martinez",
      "text": "That makes total sense. Let me send you our small business case study pack - we have 5 companies between 10-15 employees who've been with us for over a year. And I'll get you direct access to the plan comparison tool today, no bank account required. Sound good?",
      "start_time": 412,
      "end_time": 438
    },
    {
      "index": 21,
      "speaker_name": "David Chen",
      "text": "Yeah, that would help. But one more thing - what happens if an employee doesn't want to use the marketplace? Can they opt out?",
      "start_time": 438,
      "end_time": 455
    },
    {
      "index": 22,
      "speaker_name": "Alex Martinez",
      "text": "Yes, employees can opt out. If they have coverage through a spouse or other source, they don't have to participate. You just wouldn't allocate the allowance to them. But they'd miss out on the tax benefit.",
      "start_time": 455,
      "end_time": 475
    },
    {
      "index": 23,
      "speaker_name": "Jennifer Park",
      "text": "Okay, that's helpful. So what are our actual next steps if we want to move forward?",
      "start_time": 475,
      "end_time": 488
    },
    {
      "index": 24,
      "speaker_name": "Alex Martinez",
      "text": "Great question. Step one - I'll send you that case study pack and get you direct access to the plan tool today. Step two - once you've reviewed, we can do a quick 15-minute call to answer any questions. Step three - if you're ready, we'll connect the bank account and get your employee census uploaded. Step four - employees select their plans. Does that timeline work?",
      "start_time": 488,
      "end_time": 525
    },
    {
      "index": 25,
      "speaker_name": "David Chen",
      "text": "I guess so. But honestly, I wish this whole process was simpler. We're busy running a business - we don't have time to become ICHRA experts.",
      "start_time": 525,
      "end_time": 545
    },
    {
      "index": 26,
      "speaker_name": "Alex Martinez",
      "text": "I hear you, David. And that feedback is really valuable - we're actually working on simplifying the onboarding flow based on feedback like yours. But for now, I'm here to make it as easy as possible. Let's start with getting you those resources today, and we can take it step by step. Sound good?",
      "start_time": 545,
      "end_time": 575
    },
    {
      "index": 27,
      "speaker_name": "Jennifer Park",
      "text": "Yeah, okay. Let's see what you send over and we'll get back to you by tomorrow.",
      "start_time": 575,
      "end_time": 590
    },
    {
      "index": 28,
      "speaker_name": "Alex Martinez",
      "text": "Perfect. I'll send everything over within the hour, and I'll also escalate that password reset issue so you can get into the platform. Thanks for your patience today, and I'll talk to you both tomorrow.",
      "start_time": 590,
      "end_time": 610
    }
  ]$$::jsonb,
  
  true, -- is_valid
  true  -- is_summarized
);

-- Now run the RAG Pipeline workflow to vectorize this transcript
-- Then you can ask questions like:
-- "What were the main objections in the TechStart Solutions call?"
-- "What friction points did Jennifer and David experience during onboarding?"
-- "What concerns did they have about bank account requirements?"
