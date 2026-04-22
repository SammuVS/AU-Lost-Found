-- Additional schema for user profiles and verification state.
-- Run this after DATABASE_SCHEMA.sql in Supabase SQL Editor.

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  status TEXT DEFAULT 'pending_verification'
    CHECK (status IN ('pending_verification', 'active')),
  email_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Optional RLS starter policies
-- ALTER TABLE users ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Users can view their own profile" ON users
--   FOR SELECT USING (auth.uid() = id);
-- CREATE POLICY "Users can update their own profile" ON users
--   FOR UPDATE USING (auth.uid() = id);
-- CREATE POLICY "Users can insert their own profile" ON users
--   FOR INSERT WITH CHECK (auth.uid() = id);
