# User Data Collection & Storage System

Complete guide to how user onboarding data is collected, saved, and displayed in the Noiseless app.

## Overview

The system collects user data through a 9-phase onboarding flow (27 screens), saves it as JSON both locally and to a backend API, and displays it in a beautifully structured profile view.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     ONBOARDING FLOW                          │
│  (OnboardingView.swift + OnboardingModel.swift)              │
│                                                              │
│  Phase 1-9: Collect user data                               │
│  → Identity, Location, Skills, Traits,                       │
│     Vision, Values, Constraints, Time Budget                 │
│                                                              │
│  Data stored in: OnboardingModel.userData                    │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│               ONBOARDING COMPLETION                          │
│          (PhaseFinalView.swift - Line 162)                   │
│                                                              │
│  User clicks "Continue" → saveUserDataAndComplete()          │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│              USER DATA MANAGER                               │
│          (UserDataManager.swift)                             │
│                                                              │
│  Saves data to:                                              │
│  1. Local Storage (UserDefaults as JSON)                     │
│  2. Backend API (POST /user-data)                            │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│               PROFILE DISPLAY                                │
│          (ProfileDetailsView.swift)                          │
│                                                              │
│  Accessed via: Settings → Profile Details                    │
│  Shows all collected data in structured sections             │
│  Allows JSON export                                          │
└─────────────────────────────────────────────────────────────┘
```

---

## Data Model

### UserData Structure

Defined in `OnboardingModel.swift`:

```swift
struct UserData: Codable {
    var identity: String = ""           // e.g., "Student", "Professional"
    var identityDetail: String = ""     // Additional details about identity
    var location: String = ""           // User's location
    var skills: [String] = []           // List of skills
    var traits: [String] = []           // Personal traits
    var source: [String] = []           // Legacy field
    var vision: [String] = []           // Future goals/vision
    var visionDetail: String = ""       // Vision details
    var values: [String] = []           // Personal values
    var constraints: [String] = []      // Life constraints
    var constraintsDetail: String = ""  // Constraint details
    var timeBudget: String = ""         // Daily time commitment
}
```

### Example JSON

```json
{
  "identity": "Student",
  "identityDetail": "Computer Science major at NYU",
  "location": "New York, NY",
  "skills": ["Programming", "Design", "Communication"],
  "traits": ["Curious", "Organized", "Creative"],
  "source": [],
  "vision": ["Career growth", "Learn new technologies"],
  "visionDetail": "I want to become a senior software engineer",
  "values": ["Learning", "Innovation", "Work-life balance"],
  "constraints": ["Limited time", "Budget conscious"],
  "constraintsDetail": "Only have 2 hours per day for personal development",
  "timeBudget": "2 hours/day"
}
```

---

## Implementation Flow

### 1. Data Collection (During Onboarding)

**Files:** Various Phase*View.swift files

Data is collected progressively as user moves through onboarding screens:

- **Phase 1 (Trust):** identity, identityDetail
- **Phase 2-4 (Data):** location, skills, traits, vision, values, constraints, timeBudget
- **Phase 5-9:** Remaining screens (social proof, paywall, etc.)

All data is stored in `OnboardingModel.userData` (in-memory) during the flow.

### 2. Data Persistence (On Completion)

**File:** `PhaseFinalView.swift:162`

When user completes onboarding:

```swift
private func saveUserDataAndComplete() {
    Task {
        // Save both locally and to backend
        try await UserDataManager.shared.saveUserDataComplete(model.userData)

        // Mark onboarding as complete
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        // Navigate to dashboard
        model.goToStep(.dashboard)
    }
}
```

### 3. Storage Strategy

**File:** `UserDataManager.swift`

The manager provides dual storage:

#### Local Storage (UserDefaults)
- **Key:** `"savedUserData"`
- **Format:** JSON data
- **Methods:**
  - `saveUserDataLocally(_ userData: UserData)`
  - `loadUserDataLocally() -> UserData?`
  - `exportUserDataAsJSON() -> String?`

#### Backend Storage (API)
- **Endpoint:** `POST /user-data`
- **Format:** JSON body
- **Methods:**
  - `saveUserDataToBackend(_ userData: UserData) async throws -> Bool`
  - `fetchUserDataFromBackend() async throws -> UserData`

#### Complete Save
```swift
// Saves to both local and backend
try await UserDataManager.shared.saveUserDataComplete(userData)
```

**Graceful Degradation:** If backend save fails, local save still succeeds and onboarding completes.

---

## Profile Display

### Navigation Path

```
Dashboard (ExamplesView)
  └─ Tab 5: Settings Icon
      └─ ProfileSettingsView (Sheet Modal)
          └─ Profile Details (NavigationLink)
              └─ ProfileDetailsView
```

### ProfileDetailsView Features

**File:** `ProfileDetailsView.swift`

1. **Structured Display**
   - Organized sections for each data category
   - Beautiful cards with icons
   - Tag-based display for arrays
   - Dark theme matching app style

2. **Data Sections**
   - Identity (with icon)
   - Location
   - Skills (as tags)
   - Traits (as tags)
   - Vision (tags + details)
   - Values (as tags)
   - Constraints (tags + details)
   - Time Budget

3. **JSON Export**
   - Export button at bottom
   - Full-screen JSON view
   - Copy to clipboard functionality
   - Pretty-printed format

4. **Error Handling**
   - Loading state with spinner
   - Error view with retry button
   - Empty state for no data
   - Graceful error messages

---

## Key Files Reference

| File | Purpose | Lines |
|------|---------|-------|
| `OnboardingModel.swift` | Data models & state management | 131 |
| `UserDataManager.swift` | Storage layer (local + backend) | ~185 |
| `PhaseFinalView.swift` | Save trigger on completion | 369 |
| `ProfileDetailsView.swift` | Display collected data | ~600 |
| `ProfileSettingsView.swift` | Settings navigation | 61 |
| `NoiselessAPIService.swift` | API configuration | 12 |

---

## Testing the System

### 1. Test Onboarding Flow

1. Reset onboarding:
```swift
UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
UserDataManager.shared.clearUserData()
```

2. Go through onboarding
3. Complete final screen
4. Check console for save confirmation:
```
✅ User data saved successfully
```

### 2. Test Profile View

1. Navigate: Dashboard → Settings (Tab 5) → Profile Details
2. Verify all collected data displays correctly
3. Test JSON export functionality

### 3. Test JSON Storage

```swift
// Print saved JSON
if let json = try? UserDataManager.shared.exportUserDataAsJSON() {
    print(json)
}
```

### 4. Verify UserDefaults

```bash
# Get app bundle ID
xcrun simctl listapps booted | grep Noiseless

# View UserDefaults
defaults read <bundle-id>
```

---

## API Integration

### Backend Setup Required

1. Implement POST `/user-data` endpoint
2. Implement GET `/user-data` endpoint
3. Update `NoiselessAPIService.baseURL` if needed

See `BACKEND_API_GUIDE.md` for complete implementation details.

### Current Configuration

```swift
// NoiselessAPIService.swift
static let baseURL = "http://192.168.18.184:6469"
```

**Note:** Update this to your production URL with HTTPS before shipping.

---

## Customization Guide

### Adding New Data Fields

1. **Update UserData model** (`OnboardingModel.swift`):
```swift
struct UserData: Codable {
    // ... existing fields
    var newField: String = ""
}
```

2. **Collect data in onboarding** (relevant Phase*View.swift):
```swift
model.userData.newField = "value"
```

3. **Display in profile** (`ProfileDetailsView.swift`):
```swift
if !data.newField.isEmpty {
    ProfileSection(title: "New Field", icon: "icon.name") {
        DataRow(label: "New Field", value: data.newField)
    }
}
```

### Changing Storage Location

To use CoreData or Realm instead of UserDefaults:

1. Modify `UserDataManager.saveUserDataLocally()`
2. Modify `UserDataManager.loadUserDataLocally()`
3. Keep the same method signatures for consistency

---

## Security Considerations

### Current State
- Local data stored in UserDefaults (unencrypted)
- Backend communication over HTTP (development)
- No authentication implemented

### Production Recommendations

1. **Encrypt Local Storage**
```swift
// Use Keychain for sensitive data
import Security

// Store in Keychain instead of UserDefaults
KeychainManager.shared.save(userData)
```

2. **Secure Backend Communication**
- Use HTTPS only
- Implement JWT authentication
- Add request signing

3. **Data Privacy**
- Add user consent for data collection
- Implement data deletion
- GDPR compliance features

---

## Troubleshooting

### Data Not Saving

**Check:**
1. Console for error messages
2. Backend API is running
3. Network connection
4. UserDefaults permissions

**Debug:**
```swift
do {
    try UserDataManager.shared.saveUserDataLocally(userData)
    print("✅ Local save successful")
} catch {
    print("❌ Local save failed: \(error)")
}
```

### Profile Shows No Data

**Check:**
1. Onboarding completed successfully
2. Data saved to UserDefaults
3. `hasCompletedOnboarding` flag is true

**Debug:**
```swift
let hasData = UserDataManager.shared.hasLocalUserData()
print("Has local data: \(hasData)")

if let data = try? UserDataManager.shared.loadUserDataLocally() {
    print("Loaded data: \(data)")
}
```

### Backend Save Failing

**Check:**
1. Backend server is running on correct port
2. IP address is correct
3. Firewall not blocking connection
4. API endpoint implemented correctly

**Debug:**
```swift
// UserDataManager will print backend errors
// Check console for:
// "Warning: Failed to save to backend..."
```

---

## Future Enhancements

### Suggested Features

1. **Edit Profile**
   - Allow users to edit their data post-onboarding
   - Add form validation
   - Update backend with changes

2. **Data Sync**
   - Sync local changes to backend periodically
   - Handle offline mode gracefully
   - Conflict resolution

3. **Profile Picture**
   - Add avatar upload
   - Integration with photo library
   - Image storage/CDN

4. **Export Options**
   - PDF export
   - Email share
   - Cloud backup

5. **Analytics**
   - Track completion rates
   - Identify drop-off points
   - A/B test onboarding flows

---

## Support

For questions or issues:
1. Check console logs for errors
2. Verify all files are properly included in Xcode project
3. Ensure backend API is implemented (see BACKEND_API_GUIDE.md)
4. Test in simulator first before device

---

**Last Updated:** 2025-12-04
**Version:** 1.0
