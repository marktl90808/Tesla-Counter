# Apple Watch Setup - Implementation Checklist

## 📋 Complete Implementation Checklist

Use this checklist to track your progress through the Apple Watch integration setup.

---

## ✅ PHASE 1: Preparation (Read the Docs)

- [ ] Read **WATCHOS_QUICK_START.md** (5 min read)
- [ ] Read **WATCHOS_VISUAL_GUIDE.md** (3 min read)
- [ ] Skim **WATCHOS_SETUP_GUIDE.md** for reference
- [ ] Understand the architecture (iPhone ↔ Watch sync)

**Estimated Time: 10 minutes**

---

## ✅ PHASE 2: Create Watch Target in Xcode (5 minutes)

- [ ] Open `Tesla Counter.xcodeproj` in Xcode
- [ ] Go to **File → New → Target**
- [ ] Select **watchOS** tab
- [ ] Select **Watch App** template
- [ ] Click **Next**
- [ ] Fill in details:
  - [ ] Product Name: `Tesla Counter Watch`
  - [ ] Organization Identifier: (matches iPhone app)
  - [ ] Language: **Swift** ✓
  - [ ] Interface: **SwiftUI** ✓
  - [ ] Lifecycle: **SwiftUI App** ✓
- [ ] Click **Finish**
- [ ] When prompted:
  - [ ] ✅ Include WatchKit App (checked)
  - [ ] ✅ Include Notification Scene (checked)
  - [ ] Click **Finish**
- [ ] Verify new folder appears: `Tesla Counter Watch/`

**Estimated Time: 5 minutes**

---

## ✅ PHASE 3: Enable App Groups (3 minutes)

### For iPhone Target:

- [ ] In Xcode, select **Tesla Counter** target
- [ ] Click **Signing & Capabilities** tab
- [ ] Click **+ Capability** button
- [ ] Search for: **App Groups**
- [ ] Double-click **App Groups** to add
- [ ] In the "App Groups" section, click **+**
- [ ] Enter: `group.com.mark-leonard.teslacounter`
- [ ] Verify it appears with a ✓ checkmark

### For Watch Target:

- [ ] In Xcode, select **Tesla Counter Watch** target
- [ ] Click **Signing & Capabilities** tab
- [ ] Click **+ Capability** button
- [ ] Search for: **App Groups**
- [ ] Double-click **App Groups** to add
- [ ] In the "App Groups" section, click **+**
- [ ] Enter: `group.com.mark-leonard.teslacounter`
- [ ] ⚠️ **IMPORTANT:** Must match iPhone app exactly
- [ ] Verify it appears with a ✓ checkmark

**Estimated Time: 3 minutes**

---

## ✅ PHASE 4: Copy Watch App Files (2 minutes)

### File 1: WatchConnectivityManager.swift

- [ ] In Xcode, navigate to Watch app:
  - [ ] Open folder: `Tesla Counter Watch`
  - [ ] Open folder: `Tesla Counter Watch` (nested)
- [ ] Right-click → New File → Swift File
- [ ] Name: `WatchConnectivityManager.swift`
- [ ] Choose target: `Tesla Counter Watch` ✓
- [ ] Create file
- [ ] Copy contents from: `WATCH_WatchConnectivityManager.swift`
- [ ] Paste into new file
- [ ] Save (Cmd + S)

### File 2: ContentView.swift

- [ ] In the Watch app folder, find existing `ContentView.swift`
- [ ] Delete the file (or back it up first)
- [ ] Create new `ContentView.swift`
- [ ] Copy contents from: `WATCH_ContentView.swift`
- [ ] Paste into new file
- [ ] Save (Cmd + S)

### File 3: Tesla_Counter_WatchApp.swift

- [ ] In the Watch app folder, find existing app entry point file
  - [ ] Might be named: `Tesla_Counter_Watch_App.swift` or similar
- [ ] Replace its contents with: `WATCH_Tesla_Counter_WatchApp.swift`
- [ ] Or create new file if needed
- [ ] Save (Cmd + S)

### Verify Target Membership:

- [ ] For each file just created/modified:
  - [ ] Select the file
  - [ ] Open File Inspector (right panel)
  - [ ] Under "Target Membership":
    - [ ] ✅ `Tesla Counter Watch` is checked
    - [ ] ❌ `Tesla Counter` is NOT checked

**Estimated Time: 2 minutes**

---

## ✅ PHASE 5: Verify iPhone App Updates (1 minute)

- [ ] Open `PhoneConnectivity.swift`
  - [ ] Verify `updateWatch()` method exists
  - [ ] Verify `sendCountsToWatch()` method exists
  - [ ] Verify enhanced `session(didReceiveMessage:)` exists

- [ ] Open `TapCountViewModel.swift`
  - [ ] Verify `incrementCountForToday()` calls `updateWatch()`
  - [ ] Verify `incrementCTForToday()` calls `updateWatch()`
  - [ ] Verify `decrementCountForToday()` calls `updateWatch()`

- [ ] Build check: **Product → Build** (Cmd + B)
  - [ ] No errors ✓
  - [ ] Minimal warnings ✓

**Estimated Time: 1 minute**

---

## ✅ PHASE 6: Build & Run on Simulator (5 minutes)

### Build iPhone App:

- [ ] In Xcode, select **iPhone simulator** (top left)
- [ ] Select a device: e.g., **iPhone 15**
- [ ] Press **Play** button (or Cmd + R)
- [ ] Wait for app to build and run
- [ ] Verify app starts without crashes
- [ ] You should see your Tesla Counter UI
- [ ] Keep it running

### Build Watch App:

- [ ] In Xcode, select **Watch simulator** (top left)
- [ ] Select **Apple Watch - X"**
  - [ ] Note: Should be paired with iPhone simulator
- [ ] Press **Play** button (or Cmd + R)
- [ ] Wait for app to build and run
- [ ] Verify Watch app starts showing counts
- [ ] Verify it says "Connected" (after ~2 seconds)

**Estimated Time: 5 minutes**

---

## ✅ PHASE 7: Test Functionality (10 minutes)

### Test 1: Watch displays initial counts
- [ ] Look at Watch simulator
- [ ] See: "Teslas: 0"
- [ ] See: "Cybertrucks: 0"
- [ ] See: "Connected" status

### Test 2: Increment Tesla from iPhone
- [ ] On iPhone simulator, tap the Tesla image
- [ ] Sound plays ✓
- [ ] Count increases to 1
- [ ] Wait 1-2 seconds
- [ ] Check Watch simulator
- [ ] Watch count also shows 1 ✓

### Test 3: Increment Tesla from Watch
- [ ] On Watch simulator, tap the "+" button next to Teslas
- [ ] Local count increases immediately on Watch
- [ ] Watch sends message to iPhone
- [ ] Check iPhone simulator
- [ ] iPhone count updated ✓
- [ ] Watch receives confirmation (count stable)

### Test 4: Decrement Tesla from Watch
- [ ] On Watch simulator, tap the "-" button next to Teslas
- [ ] Local count decreases on Watch
- [ ] iPhone count decreases ✓
- [ ] Verify no crash or error

### Test 5: Increment Cybertruck from iPhone
- [ ] On iPhone simulator, tap the CT button
- [ ] CT count increases
- [ ] Wait 1-2 seconds
- [ ] Check Watch simulator
- [ ] Watch CT count updated ✓

### Test 6: Increment Cybertruck from Watch
- [ ] On Watch simulator, tap "+" next to Cybertrucks
- [ ] Watch local count increases
- [ ] iPhone count increases ✓
- [ ] Counts match on both devices

### Test 7: Connection status
- [ ] Check Watch display
- [ ] Should show "Connected" in green
- [ ] If shows "Syncing..." in yellow, wait a moment
- [ ] Should transition to "Connected"

**Estimated Time: 10 minutes**

---

## ✅ PHASE 8: Verify Console Logs (2 minutes)

- [ ] Open Xcode Debug Console
  - [ ] View → Debug Area → Show Debug Area (Cmd + Shift + Y)
- [ ] Look for messages like:
  - [ ] ✓ "Watch session activated with state: 0"
  - [ ] ✓ "Sent count sync to watch: Tesla=X, CT=Y"
  - [ ] ✓ "Watch: Incrementing Tesla count"
  - [ ] ✓ "Received counts from iPhone: Tesla=X, CT=Y"
- [ ] No error messages about WCSession
- [ ] No crash logs

**Estimated Time: 2 minutes**

---

## ✅ PHASE 9: Optional - Test on Real Hardware (20 minutes)

### Prerequisites:
- [ ] Apple Watch paired with iPhone (via Bluetooth)
- [ ] Xcode dev team certificate matches
- [ ] iPhone and Watch on same Wi-Fi (recommended)

### Steps:
- [ ] Select iPhone device (top left in Xcode)
- [ ] Build and run iPhone app
- [ ] Verify app installs and runs
- [ ] Select Watch device (top left in Xcode)
- [ ] Build and run Watch app
- [ ] Verify Watch app installs
- [ ] Test increment/decrement on both devices
- [ ] Verify sync works correctly
- [ ] Keep both apps running for 5 minutes
- [ ] Verify stability (no crashes)

**Estimated Time: 20 minutes (optional)**

---

## ✅ PHASE 10: Cleanup (Optional)

- [ ] If you want to clean up project root:
  - [ ] Delete `WATCH_WatchConnectivityManager.swift`
  - [ ] Delete `WATCH_ContentView.swift`
  - [ ] Delete `WATCH_Tesla_Counter_WatchApp.swift`
  - [ ] Keep documentation files for reference

- [ ] Commit to Git:
  - [ ] `git add .`
  - [ ] `git commit -m "Add Apple Watch support"`
  - [ ] `git push origin main`

**Estimated Time: 2 minutes**

---

## 📊 Total Time Estimate

| Phase | Task | Time |
|-------|------|------|
| 1 | Read Documentation | 10 min |
| 2 | Create Watch Target | 5 min |
| 3 | Enable App Groups | 3 min |
| 4 | Copy Files | 2 min |
| 5 | Verify iPhone Updates | 1 min |
| 6 | Build & Run Simulators | 5 min |
| 7 | Test Functionality | 10 min |
| 8 | Verify Logs | 2 min |
| **Total** | **Without Real Device** | **38 min** |
| 9 | Real Device Testing | 20 min |
| **Total** | **With Real Device** | **58 min** |
| 10 | Cleanup | 2 min |

**🎯 You'll have a fully functional Apple Watch app in less than 1 hour!**

---

## ⚠️ Troubleshooting During Checklist

### If Watch shows "Syncing..." and doesn't change to "Connected":
- [ ] Check WCSession.isReachable in debug console
- [ ] Verify App Groups match exactly (character by character)
- [ ] Force-close both apps
- [ ] Rebuild both targets
- [ ] Try again

### If iPhone doesn't receive Watch updates:
- [ ] Verify Watch ContentView exists and has code
- [ ] Check console for error messages
- [ ] Verify sendActionToPhone() is being called
- [ ] Check PhoneConnectivity.session(didReceiveMessage:) exists

### If build fails with missing symbols:
- [ ] Verify file target membership is correct
- [ ] Check that all imports exist
- [ ] Rebuild project (Cmd + Shift + K, then Cmd + B)

### If simulator crashes:
- [ ] Check console for error messages
- [ ] Verify all required frameworks are imported
- [ ] Reset simulators: Device → Erase All Content and Settings
- [ ] Restart Xcode

---

## ✨ Success Indicators

Once you've completed all phases, you should see:

✅ Watch app displays "Teslas: 0" and "Cybertrucks: 0"
✅ Watch app displays "Connected" status
✅ iPhone increments → Watch updates within 1-2 seconds
✅ Watch increments → iPhone updates within 1-2 seconds
✅ No errors in console
✅ Both apps remain stable during testing

---

## 🎉 Final Confirmation

Once you've completed this checklist:

- [ ] I have a fully functional Apple Watch app
- [ ] Apple Watch shows current Tesla and Cybertruck counts
- [ ] I can increment/decrement from Watch
- [ ] Counts sync between iPhone and Watch
- [ ] Everything works smoothly on simulator
- [ ] No more than 1-2 minor issues

**Congratulations! Your Tesla Counter now has Apple Watch support! 🚗⌚**

---

## 📝 Notes

Use this space to track any issues or customizations:

```
Issue 1: _______________________________________________
Solution: ______________________________________________

Issue 2: _______________________________________________
Solution: ______________________________________________

Customization 1: _______________________________________
Notes: _________________________________________________

Customization 2: _______________________________________
Notes: _________________________________________________
```

---

**Your Apple Watch integration checklist**
*For Tesla Counter by Mark Leonard*
*April 17, 2026*
