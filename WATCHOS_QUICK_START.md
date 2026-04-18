# Apple Watch Integration - Quick Reference Card

## 🚀 5-Minute Quick Start

### Step 1: Create Watch Target (2 min)
```
File → New → Target
  → watchOS → Watch App
  → Product Name: "Tesla Counter Watch"
  → Click Finish
```

### Step 2: Enable App Groups (2 min)
**iPhone Target:**
```
Select Tesla Counter
→ Signing & Capabilities
→ + Capability → App Groups
→ Add: group.com.mark-leonard.teslacounter
```

**Watch Target:**
```
Select Tesla Counter Watch
→ Signing & Capabilities
→ + Capability → App Groups
→ Add: group.com.mark-leonard.teslacounter
```

### Step 3: Copy Files to Watch App (1 min)
Copy these 3 files to your Watch app:
1. `WATCH_WatchConnectivityManager.swift` → rename to `WatchConnectivityManager.swift`
2. `WATCH_ContentView.swift` → replace existing `ContentView.swift`
3. `WATCH_Tesla_Counter_WatchApp.swift` → replace existing app entry file

### Step 4: Done! ✅
The iPhone app is already updated. Just build and run!

---

## 📱 What You Get

### iPhone → Watch (Automatic)
- ✅ Current Tesla count syncs
- ✅ Current Cybertruck count syncs
- ✅ Updates every 5 seconds
- ✅ Real-time sync on changes

### Watch → iPhone (User Interaction)
- ✅ Tap "+" to increment Tesla
- ✅ Tap "-" to decrement Tesla
- ✅ Tap "+" to increment Cybertruck
- ✅ Instant sync back to iPhone

### Visual Feedback
- ✅ Red "Teslas" counter
- ✅ Green "Cybertrucks" counter
- ✅ "Connected" status indicator
- ✅ Responsive buttons with SF Symbols

---

## 🧪 How to Test

### On Simulator
```
1. Build & run iPhone app (select iPhone simulator)
2. Build & run Watch app (select Watch simulator)
3. Tap on Watch screen → iPhone count updates
4. Tap on iPhone image → Watch count updates
```

### On Real Device
```
1. Pair iPhone with Apple Watch
2. Build & run on iPhone with real device
3. Build & run on Watch with paired watch
4. Both should sync automatically
```

---

## 🔍 File Locations

After setup, your structure should be:
```
Tesla Counter Project/
├── Tesla Counter/                    (iPhone App)
│   ├── ContentView.swift
│   ├── TapCountViewModel.swift      (✅ Already updated)
│   ├── PhoneConnectivity.swift      (✅ Already updated)
│   ├── DailyCount.swift
│   └── ... other files
│
└── Tesla Counter Watch/              (📱 NEW Watch App)
    ├── Tesla Counter Watch/
    │   ├── ContentView.swift         (📄 Copy from WATCH_ContentView.swift)
    │   ├── WatchConnectivityManager.swift  (📄 Copy from WATCH_WatchConnectivityManager.swift)
    │   ├── Tesla_Counter_WatchApp.swift   (📄 Copy from WATCH_Tesla_Counter_WatchApp.swift)
    │   └── Assets.xcassets
    └── Tesla Counter Watch.entitlements
```

---

## 🎯 Key Functions

### On iPhone (Already Updated)
```swift
// Automatically called when counts change
PhoneConnectivity.shared.updateWatch()

// Receives messages from Watch
PhoneConnectivity.session(didReceiveMessage:)

// Called after increment
TapCountViewModel.shared.incrementCountForToday()
```

### On Watch (In your Watch app)
```swift
// Send action to iPhone
connectivity.sendActionToPhone("incrementTesla")

// Request current counts
connectivity.requestSyncFromPhone()

// Receive count updates
WatchConnectivityManager.teslaCount (Published)
WatchConnectivityManager.ctCount (Published)
```

---

## 🐛 Troubleshooting

### Watch doesn't update from iPhone
```
✓ Check: WCSession.default.isReachable
✓ Check: App Groups capability is identical
✓ Try: Force-close both apps and restart
```

### iPhone doesn't update from Watch
```
✓ Check: Watch app is running (not backgrounded)
✓ Check: WCSession delegate methods implemented
✓ Try: Check console for error messages
```

### "Cannot find 'TapCountViewModel' in scope"
```
✓ Add DailyCount.swift to Watch target
✓ Add TapCountViewModel.swift to Watch target
✓ Check: File Inspector → Target Membership
```

---

## 💡 Pro Tips

1. **Haptic Feedback** (Optional)
```swift
import WatchKit
WKInterfaceDevice.current().play(.success)
```

2. **Test Without Watch**
```
Xcode supports Watch simulators!
Just pair simulators together.
```

3. **Debug Messages**
Check Xcode console for sync status:
```
"Watch session activated with state: 0"
"Connected" status shows on watch
```

---

## ✨ What's Different in Your App

### Before
- Only iPhone could count
- Watch app didn't exist

### After ⭐
- iPhone counts work (unchanged)
- Watch shows current counts
- Watch can increment Tesla (+ and -)
- Watch can increment Cybertruck (+)
- Both sync in real-time
- Works offline (with fallback)

---

## 📞 Need Help?

Refer to these docs:
1. **WATCHOS_SETUP_GUIDE.md** - Detailed step-by-step
2. **WATCHOS_IMPLEMENTATION_COMPLETE.md** - Technical deep dive
3. **WATCH_*.swift files** - Copy-paste ready code

---

## 🎉 You're Ready!

The hardest part is done. Now:
1. Create Watch target (5 minutes)
2. Enable App Groups (2 minutes)
3. Copy 3 files (1 minute)
4. Build and run (2 minutes)

**Total time: ~10 minutes**

Enjoy counting Teslas from your wrist! ⌚🚗

---

*Prepared for Tesla Counter by Mark Leonard*
*April 17, 2026*
