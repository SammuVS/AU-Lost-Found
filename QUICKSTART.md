# ⚡ QUICK START GUIDE

## 🚀 Get Running in 5 Minutes

### Step 1: Install & Setup (2 min)

```bash
npm install
```

### Step 2: Create Supabase Project (1 min)

1. Go to https://supabase.com
2. Create a free account
3. Create a new project
4. Remember your project URL & anon key

### Step 3: Create Database Tables (1 min)

1. In Supabase, go to **SQL Editor**
2. Open the file: `DATABASE_SCHEMA.sql` (in project root)
3. Copy ALL the SQL
4. Paste into Supabase SQL Editor
5. Click "Run"

### Step 4: Create Environment Variables (1 min)

Create `.env.local` in project root:

```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url_here
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

Get these from Supabase Dashboard → Settings → API3

### Step 5: Create Storage Bucket (1 min)

1. In Supabase Dashboard → **Storage**
2. Click **Create a new bucket**
3. Name: `lost-found-photos`
4. Make it **PUBLIC**
5. Click **Create**

### Step 6: Run & Test! (1 min)

```bash
npm run dev
```

Visit: **http://localhost:3000**

---

## ✅ Test Checklist

After it loads, try these:

- [ ] Click "Report Found Item" and upload an item
- [ ] Go to Lost Items page
- [ ] Click "Report Lost Item"
- [ ] Search for items on each page
- [ ] Click on an item to see details
- [ ] Try the "Is Found?" button on a lost item
- [ ] Test on mobile (open DevTools, click mobile icon)

---

## 📚 Documentation

- **README.md** - Full project overview
- **IMPLEMENTATION_GUIDE.md** - Detailed setup & development
- **PROJECT_SUMMARY.md** - Complete feature list
- **DATABASE_SCHEMA.sql** - Database structure

---

## 🚢 Deploy When Ready

### Option 1: Vercel (Easiest)

```bash
# 1. Push to GitHub
# 2. Go to vercel.com
# 3. Import your GitHub repo
# 4. Add env variables
# 5. Deploy!
```

### Option 2: Other Platforms

```bash
npm run build
npm start
```

---

## ❓ Common Issues

**"Supabase credentials not found"**

- Create `.env.local` file (see Step 4)
- Restart dev server: Stop (Ctrl+C), run `npm run dev` again

**"Database tables don't exist"**

- Check if you ran the SQL from DATABASE_SCHEMA.sql
- Test in Supabase SQL Editor first

**"Images not loading"**

- Make sure `lost-found-photos` bucket is PUBLIC
- Check the bucket exists in Supabase Storage

**"Forms not submitting"**

- Check browser console (F12) for errors
- Verify Supabase credentials in .env.local

---

## 📞 Need Help?

See detailed documentation in:

- `IMPLEMENTATION_GUIDE.md` - Full setup guide
- `DATABASE_SCHEMA.sql` - Database help
- `README.md` - General overview

---

**You're all set! Happy building! 🎉**
