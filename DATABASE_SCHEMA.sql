/**
 * CAMPUSPATCH: SECURE LOST & FOUND
 * Complete Supabase Database Schema
 *
 * Instructions:
 * 1. Go to Supabase Dashboard
 * 2. Select your project
 * 3. Go to SQL Editor
 * 4. Create a new query
 * 5. Copy and paste ALL the SQL below
 * 6. Click "Run" to execute
 *
 * Time to complete: ~10 seconds
 */

-- ============================================================================
-- STEP 1: CREATE ENUM TYPES
-- ============================================================================

CREATE TYPE item_type AS ENUM (
  'Wallet',
  'Eyeglasses',
  'Keys',
  'Bag',
  'ID Card',
  'Electronics',
  'Other'
);

CREATE TYPE handed_over_to_enum AS ENUM (
  'Director''s Office',
  'Security Desk',
  'Department Office',
  'Hostel Warden'
);

CREATE TYPE who_has_it_enum AS ENUM (
  'Student',
  'Professor/Faculty',
  'Cleaner',
  'Security'
);

CREATE TYPE item_status AS ENUM (
  'Missing',
  'Found'
);

-- ============================================================================
-- STEP 2: CREATE FOUND_ITEMS TABLE
-- ============================================================================
-- Items that have been found on campus and are waiting to be claimed

CREATE TABLE found_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Photo: URL to uploaded image from Supabase Storage
  photo_url TEXT,

  -- Item Type: One of the predefined categories
  item_type item_type NOT NULL,

  -- Brand/Color: Description like "Black Leather Wallet", "Gold Glasses Frame"
  brand_color TEXT NOT NULL,

  -- Location Where Item Was Found: e.g., "Library 3F, near entrance"
  location_found TEXT NOT NULL,

  -- Where the item is currently stored
  handed_over_to handed_over_to_enum NOT NULL,

  -- Timestamp when item was recorded
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  -- User who reported the item (optional, could be "anonymous")
  created_by TEXT
);

-- Index for fast sorting and filtering
CREATE INDEX idx_found_items_created_at ON found_items(created_at DESC);

-- ============================================================================
-- STEP 3: CREATE LOST_ITEMS TABLE
-- ============================================================================
-- Items that students are looking for

CREATE TABLE lost_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Photo: URL to uploaded image from Supabase Storage (optional)
  photo_url TEXT,

  -- Type of item (Wallet, Keys, etc.)
  item_type item_type NOT NULL,

  -- Color of the item
  color TEXT NOT NULL,

  -- Brand or model (optional)
  brand TEXT,

  -- Where the item was last seen
  location_lost TEXT NOT NULL,

  -- Detailed description provided by the owner
  description TEXT NOT NULL,

  -- Current status: either "Missing" (default) or "Found"
  -- Changes to "Found" when someone uses the "Is Found?" feature
  status item_status DEFAULT 'Missing',

  -- When item was reported as lost
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  -- User ID of person reporting (required)
  created_by TEXT NOT NULL
);

-- Indexes for performance
CREATE INDEX idx_lost_items_created_at ON lost_items(created_at DESC);
CREATE INDEX idx_lost_items_status ON lost_items(status);

-- ============================================================================
-- STEP 4: CREATE FOUND_COMMENTS TABLE
-- ============================================================================
-- Records when someone finds a lost item via the "Is Found?" feature

CREATE TABLE found_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Reference to the lost item (foreign key with cascade delete)
  lost_item_id UUID NOT NULL REFERENCES lost_items(id) ON DELETE CASCADE,

  -- Who currently has the item
  who_has_it who_has_it_enum NOT NULL,

  -- Current location where the item is stored/can be retrieved
  current_location TEXT NOT NULL,

  -- When the item was found
  found_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  -- User who reported finding the item
  created_by TEXT NOT NULL
);

-- Index for quick lookups by lost_item_id
CREATE INDEX idx_found_comments_lost_item_id ON found_comments(lost_item_id);

-- ============================================================================
-- STEP 5: CREATE NOTIFICATION_TYPE ENUM
-- ============================================================================

CREATE TYPE notification_type AS ENUM (
  'DirectMatch',
  'AlgorithmicMatch'
);

-- ============================================================================
-- STEP 6: CREATE NOTIFICATIONS TABLE
-- ============================================================================
-- Automated notifications sent to lost item owners when matches are found

CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- The lost item that matched
  lost_item_id UUID NOT NULL REFERENCES lost_items(id) ON DELETE CASCADE,

  -- The found item that triggered the notification
  found_item_id UUID NOT NULL REFERENCES found_items(id) ON DELETE CASCADE,

  -- Type of match notification
  notification_type notification_type NOT NULL,

  -- Who reported finding the item (user who clicked "Is Found?" or posted found item)
  sent_by TEXT NOT NULL,

  -- The original lost item owner who receives this notification
  sent_to TEXT NOT NULL,

  -- Match details: which fields matched
  matched_fields TEXT[], -- e.g., ARRAY['item_type', 'color', 'location']

  -- Whether the notification has been read
  is_read BOOLEAN DEFAULT false,

  -- Message body (customizable for different match types)
  message TEXT,

  -- When the notification was created
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  -- When the notification was read
  read_at TIMESTAMP WITH TIME ZONE
);

-- Indexes for performance
CREATE INDEX idx_notifications_lost_item_id ON notifications(lost_item_id);
CREATE INDEX idx_notifications_found_item_id ON notifications(found_item_id);
CREATE INDEX idx_notifications_sent_to ON notifications(sent_to);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);

-- ============================================================================
-- OPTIONAL: ENABLE ROW LEVEL SECURITY (for production)
-- ============================================================================
-- Uncomment these lines when you implement user authentication

-- ALTER TABLE found_items ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE lost_items ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE found_comments ENABLE ROW LEVEL SECURITY;

-- CREATE POLICY "Anyone can view found items" ON found_items
--   FOR SELECT USING (true);

-- CREATE POLICY "Anyone can create found items" ON found_items
--   FOR INSERT WITH CHECK (true);

-- CREATE POLICY "Anyone can view lost items" ON lost_items
--   FOR SELECT USING (true);

-- CREATE POLICY "Anyone can create lost items" ON lost_items
--   FOR INSERT WITH CHECK (true);

-- CREATE POLICY "Anyone can view found comments" ON found_comments
--   FOR SELECT USING (true);

-- CREATE POLICY "Anyone can create found comments" ON found_comments
--   FOR INSERT WITH CHECK (true);

-- ============================================================================
-- NEXT STEPS AFTER RUNNING THIS SQL:
-- ============================================================================
--
-- 1. Create Storage Bucket:
--    - Go to Storage → Buckets
--    - Create new bucket: "lost-found-photos"
--    - Set to PUBLIC
--
-- 2. Configure Environment Variables:
--    - Create .env.local in your Next.js project
--    - Add your Supabase credentials:
--      NEXT_PUBLIC_SUPABASE_URL=your_project_url
--      NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
--
-- 3. Test the Connection:
--    - Run: npm run dev
--    - Visit: http://localhost:3000
--    - Try uploading an item
--
-- ============================================================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================================================
--
-- Uncomment below to add test data to your database:

-- INSERT INTO found_items (photo_url, item_type, brand_color, location_found, handed_over_to, created_by)
-- VALUES 
--   (NULL, 'Wallet', 'Black leather wallet with gold accents', 'Library 3rd floor near entrance', 'Security Desk', 'anonymous'),
--   (NULL, 'Keys', 'Silver keys on blue keychain', 'Cafeteria near serving counter', 'Director''s Office', 'anonymous'),
--   (NULL, 'Eyeglasses', 'Black frame glasses, Ray-Ban style', 'Sports field north side', 'Hostel Warden', 'anonymous');

-- INSERT INTO lost_items (item_type, color, brand, location_lost, description, created_by)
-- VALUES
--   ('Wallet', 'Black', 'Leather', 'Library 3rd floor', 'Black leather wallet with student ID and driver license inside. Has family photos.', 'anonymous'),
--   ('Electronics', 'White', 'Apple AirPods Pro', 'Classroom Building B201', 'White Apple AirPods Pro in white charging case. Left during morning lecture.', 'anonymous'),
--   ('Keys', 'Silver', NULL, 'Cafeteria', 'Silver keys on blue keychain with "Home" tag. About 5 keys total.', 'anonymous');

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
