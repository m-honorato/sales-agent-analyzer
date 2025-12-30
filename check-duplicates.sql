-- =====================================================
-- CHECK FOR DUPLICATE VECTORIZED CHUNKS
-- Run this in Supabase SQL Editor to find duplicates
-- =====================================================

-- Find chunks with the same parent_id, chunk_index, and vector_type
-- (These should be unique - if duplicates exist, they'll show up here)
SELECT 
  metadata->>'parent_id' as parent_id,
  metadata->>'title' as title,
  metadata->>'chunk_index' as chunk_index,
  metadata->>'vector_type' as vector_type,
  COUNT(*) as duplicate_count,
  array_agg(id::text) as chunk_ids
FROM transcripts_vectorized
GROUP BY 
  metadata->>'parent_id',
  metadata->>'chunk_index',
  metadata->>'vector_type'
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Check if TechStart Solutions has duplicates
SELECT 
  id,
  metadata->>'title' as title,
  metadata->>'chunk_index' as chunk_index,
  metadata->>'vector_type' as vector_type,
  created_at
FROM transcripts_vectorized
WHERE metadata->>'title' ILIKE '%TechStart%'
ORDER BY metadata->>'chunk_index', created_at;

-- Check transcripts that are marked as vectorized but might have been re-processed
SELECT 
  tp.id,
  tp.title,
  tp.is_vectorized,
  COUNT(tv.id) as vector_count
FROM transcripts_processed tp
LEFT JOIN transcripts_vectorized tv ON tv.metadata->>'parent_id' = tp.id::text
WHERE tp.title ILIKE '%TechStart%'
GROUP BY tp.id, tp.title, tp.is_vectorized;
