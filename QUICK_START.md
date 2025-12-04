# Quick Start Guide - User Data System

## What Was Implemented

✅ **Complete user data collection and storage system** for your Noiseless onboarding flow!

### Files Created/Modified

**New Files:**
1. [UserDataManager.swift](Noiseless/UserDataManager.swift) - Handles all data persistence (local + backend)
2. [ProfileDetailsView.swift](Noiseless/ProfileDetailsView.swift) - Beautiful profile display with JSON export
3. [BACKEND_API_GUIDE.md](BACKEND_API_GUIDE.md) - Complete backend implementation guide
4. [USER_DATA_SYSTEM.md](USER_DATA_SYSTEM.md) - System architecture documentation
5. [QUICK_START.md](QUICK_START.md) - This file

**Modified Files:**
1. [PhaseFinalView.swift](Noiseless/PhaseFinalView.swift) - Added automatic data saving on completion
2. [ProfileSettingsView.swift](Noiseless/ProfileSettingsView.swift) - Added navigation to profile details
3. [NoiselessAPIService.swift](Noiseless/NoiselessAPIService.swift) - Added API endpoint docs

---

## Add Files to Xcode Project

**IMPORTANT:** You need to add the new Swift files to your Xcode project:

1. Open `Noiseless.xcodeproj` in Xcode
2. Right-click on your project folder in the navigator
3. Select "Add Files to Noiseless..."
4. Add these files:
   - `UserDataManager.swift`
   - `ProfileDetailsView.swift`
5. Make sure "Copy items if needed" is **unchecked** (files are already in place)
6. Make sure "Add to targets: Noiseless" is **checked**
7. Click "Add"

---

## How It Works

### 1. During Onboarding
- User fills out 9 phases of onboarding
- Data stored in memory: `OnboardingModel.userData`

### 2. On Completion (Final Welcome Screen)
- User clicks "Continue"
- `saveUserDataAndComplete()` is called
- Data saved to:
  - ✅ **Local Storage** (UserDefaults as JSON)
  - ✅ **Backend API** (POST /user-data)
- Onboarding marked complete
- User sees dashboard

### 3. Viewing Profile
- Dashboard → Settings (Tab 5) → **Profile Details**
- Shows all collected data beautifully structured
- Can export as JSON

---

## Testing Steps

### Step 1: Reset Onboarding (Optional)

Add this temporary code somewhere to test:

```swift
// Reset for testing
UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
UserDataManager.shared.clearUserData()
```

### Step 2: Go Through Onboarding

1. Launch app
2. Complete all onboarding phases
3. Fill in data at each step
4. Watch console for: `✅ User data saved successfully`

### Step 3: View Your Profile

1. Navigate to Dashboard
2. Tap Settings icon (Tab 5)
3. Tap "Profile Details"
4. See all your data!
5. Tap "Export as JSON" to see raw data

### Step 4: Test JSON Storage

Check UserDefaults in Xcode debugger:

```swift
po UserDefaults.standard.data(forKey: "savedUserData")
po try? UserDataManager.shared.exportUserDataAsJSON()
```

---

## Backend Setup (Required for Full Functionality)

The app will work locally without a backend, but to enable full sync:

### Quick Test Server (Node.js)

1. Create `server.js`:

```javascript
const express = require('express');
const app = express();
app.use(express.json());

let userData = {};

app.post('/user-data', (req, res) => {
  userData = req.body;
  console.log('Saved:', userData);
  res.json({ success: true, message: 'Saved' });
});

app.get('/user-data', (req, res) => {
  res.json(userData);
});

app.listen(6469, '0.0.0.0', () => {
  console.log('Server on http://0.0.0.0:6469');
});
```

2. Run:
```bash
npm install express
node server.js
```

3. Update IP in `NoiselessAPIService.swift` if needed

For full implementation, see [BACKEND_API_GUIDE.md](BACKEND_API_GUIDE.md)

---

## What Data Gets Saved?

All onboarding data:

```json
{
  "identity": "Student",
  "identityDetail": "Details about role",
  "location": "New York",
  "skills": ["Programming", "Design"],
  "traits": ["Curious", "Organized"],
  "vision": ["Career growth"],
  "visionDetail": "Long-term goals",
  "values": ["Learning", "Innovation"],
  "constraints": ["Time", "Budget"],
  "constraintsDetail": "Specific constraints",
  "timeBudget": "2 hours/day"
}
```

---

## Profile View Features

### Organized Sections
- 🔹 Identity
- 📍 Location
- ⭐ Skills (as tags)
- ✨ Traits (as tags)
- 👁️ Vision
- ❤️ Values (as tags)
- 🛡️ Constraints
- ⏰ Time Budget

### Actions
- **Export JSON** - Full data export
- **Copy to Clipboard** - Easy sharing
- **Pretty Formatting** - Readable display

---

## Troubleshooting

### "UserDataManager not found" error
→ Add `UserDataManager.swift` to Xcode project (see instructions above)

### "ProfileDetailsView not found" error
→ Add `ProfileDetailsView.swift` to Xcode project (see instructions above)

### Data not saving
→ Check console for errors
→ Ensure backend is running (or ignore backend errors - local save still works)

### Profile shows no data
→ Complete onboarding first
→ Check: `UserDataManager.shared.hasLocalUserData()`

### Backend connection fails
→ This is OK! Local save still works
→ Check backend server is running
→ Verify IP address in `NoiselessAPIService.swift`

---

## Next Steps

### Immediate
1. ✅ Add new Swift files to Xcode project
2. ✅ Build and test in simulator
3. ✅ Complete onboarding flow
4. ✅ View profile details

### Optional
1. 🔧 Set up backend API (see BACKEND_API_GUIDE.md)
2. 🎨 Customize profile view colors/layout
3. 🔐 Add authentication
4. ☁️ Deploy backend to production

### Future Enhancements
- Edit profile functionality
- Profile picture upload
- PDF export
- Data sync indicator
- Offline mode improvements

---

## Support

**Architecture Docs:** [USER_DATA_SYSTEM.md](USER_DATA_SYSTEM.md)
**Backend Guide:** [BACKEND_API_GUIDE.md](BACKEND_API_GUIDE.md)

**Check Console Logs:**
- `✅ User data saved successfully` - All good!
- `❌ Error saving user data: ...` - Check error message
- `Warning: Failed to save to backend...` - Backend issue (local save succeeded)

---

## Visual Flow

```
┌─────────────────────┐
│  Onboarding Flow    │
│  (27 screens)       │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Final Welcome      │
│  User clicks        │
│  "Continue"         │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Save Data          │
│  • UserDefaults     │
│  • Backend API      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Dashboard          │
│  (App ready!)       │
└─────────────────────┘

To view saved data:
Dashboard → Settings → Profile Details
```

---

**Implementation Date:** 2025-12-04
**Status:** ✅ Ready to Test
**Files Modified:** 3
**Files Created:** 5
**Lines Added:** ~1000+

Happy coding! 🚀
