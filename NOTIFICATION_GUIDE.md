# CampusPatch Notification System Guide

## Overview

The CampusPatch notification system automatically closes the loop between losing and finding items on campus. It provides two types of notifications to keep lost item owners informed about potential matches:

1. **Direct Match Notifications** - When someone clicks "Is Found?" on a lost item
2. **Algorithmic Match Notifications** - When a new found item matches lost items based on type, color, and location

---

## Features

### 🎯 Direct Match Notifications

**When**: A user clicks "Is Found?" on a lost item detail page

**What happens**:

1. User fills out the "Is Found?" form with:
   - Who currently has the item (Student/Professor/Cleaner/Security)
   - Current location
2. The system creates a record in the `found_comments` table
3. Updates the lost item status to "Found"
4. **Sends an immediate notification** to the original lost item owner with:
   - Confirmation that their item was found
   - Who has it
   - Where to pick it up

**Message**:

```
Great news! Your [item_type] has been found!
It's currently with [who_has_it] at [current_location].
Please contact them to arrange pickup.
```

### 📬 Algorithmic Match Notifications

**When**: A new found item is posted

**How it works**:

1. A user posts a found item with:
   - Item type (Wallet, Keys, Electronics, etc.)
   - Color/Brand description
   - Location found
2. The system scans all "Missing" lost items in the database
3. Calculates a match score based on:
   - **Item Type** (40 points) - Exact match
   - **Color** (30 points) - Item color matches
   - **Location** (30 points) - Location similarity
4. **Sends notifications** to lost item owners with a match score of 40+ points

**Match Confidence Levels**:

- **Perfect Match** (100 points): All fields match
  - Message: "Perfect match! A [item] matching your lost item has been found..."
- **High Probability** (70+ points): Most fields match
  - Message: "High probability match! A [item] with matching color found..."
- **Potential Match** (40+ points): At least one field matches
  - Message: "Potential match found! A [item] has been found..."

---

## Database Schema

### `notifications` Table

```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY,
  lost_item_id UUID REFERENCES lost_items(id),
  found_item_id UUID REFERENCES found_items(id),
  notification_type ENUM ('DirectMatch', 'AlgorithmicMatch'),
  sent_by TEXT,  -- User who reported the found item
  sent_to TEXT,  -- Lost item owner
  matched_fields TEXT[],  -- e.g., ['item_type', 'color', 'location']
  is_read BOOLEAN DEFAULT false,
  message TEXT,
  created_at TIMESTAMP,
  read_at TIMESTAMP
);
```

---

## How to Use

### For Lost Item Owners

1. **Report a Lost Item**
   - Go to Lost Items page
   - Click "Report Missing"
   - Fill in details: type, color, location, description
2. **Receive Notifications**
   - Click the 🔔 bell icon in the header
   - See all notifications about your lost item
   - Notifications show:
     - Type of notification (Found vs Potential Match)
     - Match details
     - Quick "View Item" button

3. **Take Action**
   - Click "View Item" to see the found item details
   - Contact the person who has it
   - Arrange pickup location and time

### For Finders

1. **Post Found Items**
   - Go to Found Items page
   - Click "Report Found Item"
   - Upload photo (optional)
   - Fill in: type, color, location, where it's stored

2. **Automatic Notifications Sent**
   - System scans lost items database
   - Matching lost item owners get notified
   - No manual action needed!

---

## Notification Service API

### Location: `src/lib/notificationService.ts`

#### Function: `sendDirectMatchNotification()`

```typescript
sendDirectMatchNotification(
  lostItemId: string,
  foundItemId: string,
  finderIdentifier: string,
  location: string
): Promise<Notification | null>
```

Sends a direct match notification when "Is Found?" is clicked.

#### Function: `sendAlgorithmicMatchNotifications()`

```typescript
sendAlgorithmicMatchNotifications(
  newFoundItem: FoundItem
): Promise<Notification[]>
```

Scans lost items and sends notifications for matches.

#### Function: `getUserNotifications()`

```typescript
getUserNotifications(
  userId: string,
  unreadOnly?: boolean
): Promise<Notification[]>
```

Fetch notifications for a specific user.

#### Function: `markNotificationAsRead()`

```typescript
markNotificationAsRead(notificationId: string): Promise<boolean>
```

Mark a notification as read.

#### Function: `getUnreadNotificationCount()`

```typescript
getUnreadNotificationCount(userId: string): Promise<number>
```

Get count of unread notifications.

#### Function: `deleteNotification()`

```typescript
deleteNotification(notificationId: string): Promise<boolean>
```

Delete a notification.

---

## Components

### `NotificationBell` Component

- Location: `src/components/NotificationBell.tsx`
- Shows bell icon with unread count badge
- Placed in header for quick access
- Polls for updates every 10 seconds

### `NotificationsPanel` Component

- Location: `src/components/NotificationsPanel.tsx`
- Sliding panel from right side
- Shows all user notifications
- Features:
  - Filter by type (Found/Potential Match)
  - Mark as read
  - Quick navigation to item
  - Delete notifications
  - Shows matched fields
  - Timestamp for each notification

---

## Integration Points

### ItemDetailView Component

- **File**: `src/components/ItemDetailView.tsx`
- **When**: User submits "Is Found?" form
- **Action**: Calls `sendDirectMatchNotification()`
- **Line**: After updating lost item status

### AddFoundItemForm Component

- **File**: `src/components/AddFoundItemForm.tsx`
- **When**: New found item is created
- **Action**: Calls `sendAlgorithmicMatchNotifications()`
- **Line**: After inserting found item into database

### Header Component

- **File**: `src/components/Header.tsx`
- **Action**: Displays NotificationBell and NotificationsPanel
- **Position**: Right side of header, before auth section

---

## Matching Algorithm

### Score Calculation

```
Total Score = Item Type Points + Color Points + Location Points

Item Type Match: +40 points
- Matches if both items have the same type
- Example: "Wallet" matches "Wallet"

Color Match: +30 points
- Matches if brand_color contains or is contained in lost color
- Example: "Black Leather Wallet" matches "Black"

Location Match: +30 points
- Matches if found location shares first word with lost location
- Example: "Library 3F" matches "Library East Wing"

Minimum threshold for notification: 40 points
```

### Example Matches

| Lost Item             | Found Item                         | Score | Type             |
| --------------------- | ---------------------------------- | ----- | ---------------- |
| Black Wallet, Library | Black wallet, Library 3F           | 100   | Perfect Match    |
| Red Keys, Cafe        | Red keychain, Cafeteria            | 70    | High Probability |
| Gold Glasses, Gym     | Gold frame glasses, Sports Complex | 40    | Potential Match  |

---

## Testing the System

### Manual Testing Steps

1. **Direct Match Test**:
   - Create a lost item: "Black Wallet at Library"
   - Go to item details
   - Click "Is Found?"
   - Fill form: "Student at Security Desk"
   - Check notifications panel - should see direct match

2. **Algorithmic Match Test**:
   - Create a lost item: "Black Wallet at Library"
   - Go to Found Items
   - Create found item: "Black Wallet at Library"
   - Check notifications - algorithmic match should appear

3. **Browser Console**:
   ```javascript
   // Check for notification logs
   console.log("✅ Direct match notification sent");
   console.log("✅ Algorithmic match notification sent");
   ```

---

## Configuration

### Settings in `notificationService.ts`

**Minimum Match Score**: Line ~120

```typescript
if (score >= 40 && matchedFields.length >= 1)
```

- Default: 40 points
- Increase to reduce false positives
- Decrease to increase sensitivity

**Polling Interval** (NotificationBell): 10 seconds

- Location: `src/components/NotificationBell.tsx`
- Change: `setInterval(fetchUnreadCount, 10000)`
- 10000ms = 10 seconds

---

## Future Enhancements

- [ ] Push notifications to mobile devices
- [ ] Email notifications
- [ ] SMS notifications to phone number
- [ ] Real-time updates using Supabase Realtime
- [ ] Notification preferences/settings
- [ ] Block notifications from specific users
- [ ] Notification history/archive
- [ ] Notification templates customization
- [ ] Multi-language support
- [ ] Notification scheduling (quiet hours)

---

## Troubleshooting

### Notifications Not Sending

**Check**:

1. Verify `notifications` table exists in Supabase
2. Check browser console for errors
3. Verify user ID is correct (should be email or "anonymous")
4. Ensure `created_by` field is populated on items

### Notifications Not Appearing

**Check**:

1. Clear browser cache
2. Hard refresh (Ctrl+Shift+R)
3. Check if notifications are marked as read
4. Verify `sent_to` field matches current user ID

### Wrong Matches

**Adjust**:

1. Increase minimum score threshold
2. Make color/location matching more strict
3. Require item type match only (set other scores to 0)

---

## API Reference Summary

| Function                              | Purpose                                   | Returns              |
| ------------------------------------- | ----------------------------------------- | -------------------- |
| `sendDirectMatchNotification()`       | Send notification for clicked "Is Found?" | Notification \| null |
| `sendAlgorithmicMatchNotifications()` | Scan and match lost items                 | Notification[]       |
| `getUserNotifications()`              | Fetch user's notifications                | Notification[]       |
| `markNotificationAsRead()`            | Mark as read                              | boolean              |
| `markAllNotificationsAsRead()`        | Mark all as read                          | boolean              |
| `getUnreadNotificationCount()`        | Get unread count                          | number               |
| `deleteNotification()`                | Delete notification                       | boolean              |

---

## Database Setup Instructions

Run the updated `DATABASE_SCHEMA.sql` file:

```sql
-- The schema now includes the notifications table
-- It will be created automatically with all the other tables
-- Just run the entire DATABASE_SCHEMA.sql script
```

---

## Summary

The notification system is a fully automated solution that:

- ✅ Notifies lost item owners when items are found
- ✅ Suggests potential matches automatically
- ✅ Close the loop on lost-found interactions
- ✅ Easy to use - no manual notification management
- ✅ Scalable - works for any number of items

**Success metrics**:

- Increased item recovery rate
- Faster item return to owners
- Improved user satisfaction
- Better campus community connections
