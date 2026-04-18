# Apple Watch Integration - Visual Guide

## 🎯 System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      iPhone App                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  ContentView                                             │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐         │  │
│  │  │ Tap Tesla  │  │  Tap CT    │  │   History  │         │  │
│  │  │   Image    │  │   Button   │  │    View    │         │  │
│  │  └────────┬───┘  └────────┬───┘  └────────────┘         │  │
│  │           │               │                             │  │
│  │           └───────┬───────┘                             │  │
│  │                   ▼                                     │  │
│  │    TapCountViewModel.shared                            │  │
│  │    ┌─────────────────────────────────┐               │  │
│  │    │ @Published var t: Int           │               │  │
│  │    │ @Published var ct: Int          │               │  │
│  │    │                                 │               │  │
│  │    │ incrementCountForToday()        │               │  │
│  │    │ incrementCTForToday()           │               │  │
│  │    │ decrementCountForToday()        │               │  │
│  │    └────────────┬────────────────────┘               │  │
│  │                │                                      │  │
│  │                ▼ [Updated!]                          │  │
│  │    PhoneConnectivity.shared.updateWatch()           │  │
│  │    ┌──────────────────────────────────────────┐     │  │
│  │    │ WCSession.sendMessage({                 │     │  │
│  │    │   "teslaCount": X,                       │     │  │
│  │    │   "ctCount": Y                           │     │  │
│  │    │ })                                        │     │  │
│  │    └────────────┬─────────────────────────────┘     │  │
│  │                │                                    │  │
│  └────────────────┼────────────────────────────────────┘  │
│                   │                                      │  │
│                   │ WatchConnectivity                   │  │
│                   │ (BidirectionalSync)                │  │
│                   │                                      │  │
└───────────────────┼──────────────────────────────────────┘
                    │
                    │◄──────┐
                    │       │ (Messages sent to Watch)
                    ▼       │ (Messages received from Watch)
┌───────────────────────────┼──────────────────────────────────┐
│                   Watch App│                                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  ContentView (watchOS)                               │   │
│  │  ┌──────────────┐  ┌──────────────┐                │   │
│  │  │  Teslas: 42  │  │ Cybertrucks: 5 │              │   │
│  │  │  [-] [+]     │  │  [+]         │              │   │
│  │  └────────┬─────┘  └──────┬───────┘              │   │
│  │           │               │                      │   │
│  │           └───────┬───────┘                      │   │
│  │                   ▼                              │   │
│  │    WatchConnectivityManager.shared              │   │
│  │    ┌────────────────────────────────────────┐   │   │
│  │    │ @Published var teslaCount: Int         │   │   │
│  │    │ @Published var ctCount: Int            │   │   │
│  │    │ @Published var isWatchReachable: Bool  │   │   │
│  │    │                                        │   │   │
│  │    │ sendActionToPhone("action")            │   │   │
│  │    │ requestSyncFromPhone()                 │   │   │
│  │    └────────────┬─────────────────────────┘   │   │
│  │                │                              │   │
│  │                ▼                              │   │
│  │    WCSession.sendMessage({                   │   │
│  │      "action": "incrementTesla"              │   │
│  │    })                                         │   │
│  │                │                              │   │
│  └────────────────┼──────────────────────────────┘   │
│                   │                                  │
│                   ▼ [Routes back to iPhone]         │
└──────────────────────────────────────────────────────┘
```

---

## 📊 Count Increment Flow

### Scenario: User taps "+" on Watch to increment Tesla

```
┌──────────────────────────────────────────────────────────┐
│  1. Watch UI - User Action                              │
│     └─ Button("plus.circle.fill") tapped                │
└─────────────────────┬──────────────────────────────────┘
                      ▼
┌──────────────────────────────────────────────────────────┐
│  2. Watch - incrementTesla()                            │
│     ┌─ teslaCount += 1  [Local state update]            │
│     └─ sendActionToPhone("incrementTesla")              │
└─────────────────────┬──────────────────────────────────┘
                      ▼
┌──────────────────────────────────────────────────────────┐
│  3. Watch → iPhone Communication                        │
│     ┌─ WCSession.sendMessage({                          │
│     │   "action": "incrementTesla"                      │
│     │ })                                                │
│     └─ isReachable? Use sendMessage : updateContext     │
└─────────────────────┬──────────────────────────────────┘
                      ▼
┌──────────────────────────────────────────────────────────┐
│  4. iPhone - Receives Message                           │
│     └─ PhoneConnectivity.session(didReceiveMessage:)    │
└─────────────────────┬──────────────────────────────────┘
                      ▼
┌──────────────────────────────────────────────────────────┐
│  5. iPhone - Process Action                             │
│     ┌─ if action == "incrementTesla":                   │
│     │   TapCountViewModel.incrementCountForToday()      │
│     └─                                                  │
└─────────────────────┬──────────────────────────────────┘
                      ▼
┌──────────────────────────────────────────────────────────┐
│  6. iPhone - Update State                               │
│     ┌─ tapCounts[today].t += 1                          │
│     ├─ @Published var t = new value                     │
│     ├─ saveCounts() to UserDefaults                     │
│     └─ playSound() if celebration multiple hit          │
└─────────────────────┬──────────────────────────────────┘
                      ▼
┌──────────────────────────────────────────────────────────┐
│  7. iPhone - Send Update Back                           │
│     └─ PhoneConnectivity.updateWatch()                  │
│        └─ WCSession.sendMessage({                       │
│             "teslaCount": 43,                           │
│             "ctCount": 5                                │
│           })                                            │
└─────────────────────┬──────────────────────────────────┘
                      ▼
┌──────────────────────────────────────────────────────────┐
│  8. Watch - Receives Count Update                       │
│     └─ WatchConnectivityManager.session(didReceiveMessage:)
│        ├─ teslaCount = 43                               │
│        └─ ctCount = 5                                   │
└─────────────────────┬──────────────────────────────────┘
                      ▼
┌──────────────────────────────────────────────────────────┐
│  9. Watch UI - Updates Automatically                    │
│     ├─ @ObservedObject watches teslaCount              │
│     ├─ ContentView refreshes                           │
│     └─ Text("43") displays on screen                   │
└──────────────────────────────────────────────────────────┘
```

---

## 🔄 Periodic Sync Flow

```
Every 5 seconds on Watch:

┌────────────────────────────────────────┐
│  Timer.publish(every: 5).autoconnect() │
└──────────────┬─────────────────────────┘
               ▼
┌────────────────────────────────────────┐
│  requestSync()                         │
│  connectivity.requestSyncFromPhone()   │
└──────────────┬─────────────────────────┘
               ▼
┌────────────────────────────────────────┐
│  WCSession.sendMessage({               │
│    "action": "requestSync"             │
│  })                                    │
└──────────────┬─────────────────────────┘
               ▼
┌────────────────────────────────────────┐
│  iPhone receives                       │
│  PhoneConnectivity handles reply       │
│  Sends back current counts             │
└──────────────┬─────────────────────────┘
               ▼
┌────────────────────────────────────────┐
│  Watch receives counts                 │
│  Updates @Published vars               │
│  UI automatically refreshes            │
└────────────────────────────────────────┘
```

---

## 📈 State Management

### iPhone App State
```
UserDefaults
    ↓
[DailyCount] array
    ↓
TapCountViewModel
    ├─ @Published var t: Int
    ├─ @Published var ct: Int
    └─ @Published var tapCounts: [DailyCount]
        ↓
    ContentView observes changes
        ↓
    UI updates
```

### Watch App State
```
WatchConnectivityManager
    ├─ @Published var teslaCount: Int
    ├─ @Published var ctCount: Int
    └─ @Published var isWatchReachable: Bool
        ↓
    ContentView observes changes
        ↓
    Watch display updates
```

### Sync State
```
iPhone (source of truth)
    ↓
    WCSession.sendMessage()
    ↓
Watch (receives updates)
    ↓
    User taps button
    ↓
    WCSession.sendMessage()
    ↓
iPhone (processes action)
    ↓
    Updates and syncs back
    ↓
Watch (receives updated counts)
```

---

## 🎨 Watch UI Layout

```
┌─────────────────────────────────────┐
│  ┌─────────────────────────────────┐│
│  │   Tesla Counter     [Headline]   ││
│  ├─────────────────────────────────┤│
│  │                                 ││
│  │         Teslas      [Caption]   ││
│  │           42        [Title]     ││
│  │        [-] [+]      [Buttons]   ││
│  │                                 ││
│  ├─────────────────────────────────┤│
│  │                                 ││
│  │      Cybertrucks    [Caption]   ││
│  │           5         [Title]     ││
│  │          [+]        [Button]    ││
│  │                                 ││
│  ├─────────────────────────────────┤│
│  │                                 ││
│  │       Connected     [Status]    ││
│  │       (or Syncing...)           ││
│  │                                 ││
│  └─────────────────────────────────┘│
└─────────────────────────────────────┘

Colors:
- Red text: Tesla counts (matches iPhone)
- Green text: Cybertruck counts (matches iPhone)
- Green status: Connected
- Yellow status: Syncing
```

---

## 🔐 App Groups Purpose

```
App Group: group.com.mark-leonard.teslacounter

┌─────────────────┐         ┌─────────────────┐
│  iPhone App     │         │  Watch App      │
│                 │         │                 │
│  Membership:    │────────▶│  Membership:    │
│  group.xyz      │  Same   │  group.xyz      │
└─────────────────┘  ID     └─────────────────┘

Allows:
1. Shared UserDefaults
2. Shared file container
3. Shared Keychain (if implemented)
4. Coordinated file access

For now: Used for WCSession coordination
```

---

## 📱 Message Types

### Action Messages (Watch → iPhone)
```swift
// Button: Increment Tesla
["action": "incrementTesla"]

// Button: Decrement Tesla
["action": "decrementTesla"]

// Button: Increment Cybertruck
["action": "incrementCT"]

// Request current counts
["action": "requestSync"]
```

### Count Update Messages (iPhone → Watch)
```swift
// Unsolicited update
[
    "teslaCount": 42,
    "ctCount": 5,
    "timestamp": 1713360000.0
]

// Reply to requestSync
[
    "teslaCount": 42,
    "ctCount": 5
]
```

---

## ✅ Connectivity States

```
┌────────────────────────────────────────────┐
│  WCSession States                          │
├────────────────────────────────────────────┤
│                                            │
│  isReachable = true                        │
│  └─ iPhone & Watch connected               │
│     └─ Use sendMessage() [fast, sync]      │
│                                            │
│  isReachable = false                       │
│  └─ Devices separated                      │
│     └─ Use updateApplicationContext()      │
│        (stores data for later delivery)    │
│                                            │
└────────────────────────────────────────────┘

When both are available:
├─ iPhone taps → Instant sync to Watch
├─ Watch taps → Instant sync to iPhone
└─ Both refresh every 5 seconds anyway
```

---

## 🚀 Deployment Flow

```
Development
    ├─ Write code (✓ Done)
    ├─ Add Watch target (You'll do this)
    ├─ Enable App Groups (You'll do this)
    ├─ Copy files (You'll do this)
    └─ Build & test
        ├─ Simulator tests
        └─ Real device tests

Production
    └─ TestFlight / App Store
       ├─ Both iPhone & Watch apps deployed
       ├─ Users pair watch with iPhone
       └─ Auto-updates for both
```

---

*Visual Guide for Tesla Counter Apple Watch Integration*
*By Mark Leonard, April 17, 2026*
