# Apple Watch Integration Guide for Tesla Counter

This guide walks you through adding Apple Watch functionality to your Tesla Counter app. The Watch will display current counts and allow you to increment Tesla or Cybertruck counters directly from your wrist.

---

## 📋 Overview

After completing this setup, you'll have:
- ✅ Real-time count synchronization between iPhone and Apple Watch
- ✅ Ability to increment Tesla counts from the Watch
- ✅ Ability to increment Cybertruck (CT) counts from the Watch
- ✅ Current count display on the Watch
- ✅ Bidirectional communication via WatchConnectivity

---

## 🚀 Step-by-Step Setup Instructions

### **Step 1: Add the WatchOS Target in Xcode**

1. **Open your project** in Xcode:
   ```
   Open Tesla Counter.xcodeproj
   ```

2. **Add a new target**:
   - Go to **File → New → Target**
   - Select **watchOS** tab
   - Choose **Watch App** template
   - Click **Next**

3. **Configure the target**:
   - **Product Name**: `Tesla Counter Watch` (or similar)
   - **Organization Identifier**: Keep same as main app
   - **Language**: Swift
   - **Interface**: SwiftUI
   - **Lifecycle**: SwiftUI App
   - **Click Finish**

4. **When prompted**, select:
   - ✅ **Include WatchKit App**
   - ✅ **Include Notification Scene**
   - Click **Finish**

5. **A new folder structure will be created**:
   ```
   Tesla Counter Watch/
   ├── Tesla Counter Watch App/
   │   ├── Tesla_Counter_WatchApp.swift
   │   ├── ContentView.swift
   │   ├── Assets.xcassets/
   │   └── Preview Content/
   └── Tesla Counter Watch.entitlements
   ```

### **Step 2: Update App Groups (Enable Data Sharing)**

1. **Select the main Tesla Counter target** in Xcode
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Search for and add **App Groups**
5. Add the app group: `group.com.yourcompany.teslacounter`

6. **Repeat for Watch target**:
   - Select **Tesla Counter Watch** target
   - Go to **Signing & Capabilities**
   - Add **App Groups**
   - Use **same** app group: `group.com.yourcompany.teslacounter`

### **Step 3: Create Shared Watch Connectivity Manager**

Create a new file: **`WatchConnectivityManager.swift`** in both the main app and Watch app

**File location for iPhone app**: `Tesla Counter/WatchConnectivityManager.swift`

```swift
//
//  WatchConnectivityManager.swift
//  Tesla Counter
//
//  Created by Mark Leonard on 4/17/2026.
//

import Foundation
import WatchConnectivity

class WatchConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var teslaCount: Int = 0
    @Published var ctCount: Int = 0
    @Published var isWatchReachable: Bool = false
    
    override init() {
        super.init()
        setupWatchConnectivity()
    }
    
    func setupWatchConnectivity() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    // MARK: - WCSessionDelegate Methods
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Watch session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("Watch session deactivated")
        WCSession.default.activate()
    }
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        print("Watch session activated with state: \(activationState.rawValue)")
        DispatchQueue.main.async {
            self.isWatchReachable = session.isReachable
        }
    }
    
    // MARK: - Message Reception from Watch
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let action = message["action"] as? String {
                print("Received action from watch: \(action)")
                
                switch action {
                case "incrementTesla":
                    TapCountViewModel.shared.incrementCountForToday()
                case "incrementCT":
                    TapCountViewModel.shared.incrementCTForToday()
                case "decrementTesla":
                    TapCountViewModel.shared.decrementCountForToday()
                case "requestSync":
                    self.sendCountsToWatch()
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - Sending Data to Watch
    
    func sendCountsToWatch() {
        let viewModel = TapCountViewModel.shared
        let message: [String: Any] = [
            "teslaCount": viewModel.t,
            "ctCount": viewModel.ct,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Error sending message to watch: \(error.localizedDescription)")
            }
        } else {
            // Store in application context for later sync
            do {
                try WCSession.default.updateApplicationContext(message)
                print("Updated application context for watch")
            } catch {
                print("Error updating application context: \(error.localizedDescription)")
            }
        }
    }
    
    func notifyCountUpdate() {
        sendCountsToWatch()
    }
}
```

**File location for Watch app**: `Tesla Counter Watch/Tesla Counter Watch/WatchConnectivityManager.swift`

(Same code as above - copy it to the Watch app target)

### **Step 4: Create the Watch App Main View**

Create: **`ContentView.swift`** (replace the default one in the Watch app)

**Location**: `Tesla Counter Watch/Tesla Counter Watch/ContentView.swift`

```swift
//
//  ContentView.swift
//  Tesla Counter Watch App
//
//  Created by Mark Leonard on 4/17/2026.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @ObservedObject var connectivity = WatchConnectivityManager.shared
    @State private var teslaCount: Int = 0
    @State private var ctCount: Int = 0
    @State private var lastUpdate: Date = Date()
    
    var body: some View {
        VStack(spacing: 8) {
            // Title
            Text("Tesla Counter")
                .font(.headline)
                .lineLimit(1)
            
            Divider()
            
            // Tesla Count Display and Button
            VStack(spacing: 4) {
                Text("Teslas")
                    .font(.caption2)
                    .foregroundColor(.red)
                
                Text("\(teslaCount)")
                    .font(.system(.title, design: .monospaced))
                    .foregroundColor(.red)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Button(action: decrementTesla) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: incrementTesla) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Divider()
            
            // CT Count Display and Button
            VStack(spacing: 4) {
                Text("Cybertrucks")
                    .font(.caption2)
                    .foregroundColor(.green)
                
                Text("\(ctCount)")
                    .font(.system(.title, design: .monospaced))
                    .foregroundColor(.green)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Button(action: incrementCT) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Divider()
            
            // Sync Status
            Text(connectivity.isWatchReachable ? "Connected" : "Syncing...")
                .font(.caption)
                .foregroundColor(connectivity.isWatchReachable ? .green : .yellow)
        }
        .padding(8)
        .onAppear {
            requestSync()
        }
        .onReceive(Timer.publish(every: 5).autoconnect()) { _ in
            requestSync()
        }
    }
    
    // MARK: - Actions
    
    func incrementTesla() {
        teslaCount += 1
        sendActionToPhone("incrementTesla")
    }
    
    func decrementTesla() {
        if teslaCount > 0 {
            teslaCount -= 1
        }
        sendActionToPhone("decrementTesla")
    }
    
    func incrementCT() {
        ctCount += 1
        sendActionToPhone("incrementCT")
    }
    
    func requestSync() {
        let message: [String: String] = ["action": "requestSync"]
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message) { [weak self] replyMessage in
                DispatchQueue.main.async {
                    if let tesla = replyMessage["teslaCount"] as? Int,
                       let ct = replyMessage["ctCount"] as? Int {
                        self?.teslaCount = tesla
                        self?.ctCount = ct
                    }
                }
            }
        }
    }
    
    func sendActionToPhone(_ action: String) {
        let message: [String: String] = ["action": action]
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message) { _ in
                // Response received
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```

### **Step 5: Update iPhone's PhoneConnectivity**

The PhoneConnectivity has already been updated to support bidirectional communication. Now update the ViewModel methods:

In your main iPhone app, the code has already been updated to call `PhoneConnectivity.shared.updateWatch()` after count changes.

### **Step 6: Add Reply Handler Support**

Update your **`PhoneConnectivity.swift`** to handle reply messages from the Watch:

Add this method to `PhoneConnectivity`:

```swift
func session(_ session: WCSession, 
             didReceiveMessage message: [String: Any],
             replyHandler: @escaping ([String: Any]) -> Void) {
    DispatchQueue.main.async {
        if let action = message["action"] as? String, action == "requestSync" {
            let viewModel = TapCountViewModel.shared
            let reply: [String: Int] = [
                "teslaCount": viewModel.t,
                "ctCount": viewModel.ct
            ]
            replyHandler(reply)
            print("Sent count sync to watch: Tesla=\(viewModel.t), CT=\(viewModel.ct)")
        } else if let action = message["action"] as? String {
            switch action {
            case "incrementTesla":
                TapCountViewModel.shared.incrementCountForToday()
                print("Watch: Incrementing Tesla count")
            case "incrementCT":
                TapCountViewModel.shared.incrementCTForToday()
                print("Watch: Incrementing CT count")
            case "decrementTesla":
                TapCountViewModel.shared.decrementCountForToday()
                print("Watch: Decrementing Tesla count")
            default:
                break
            }
            replyHandler([:])
        }
    }
}
```

### **Step 7: Update ContentView.swift on iPhone**

Add this line in the `onAppear` modifier:

```swift
.onAppear {
    viewModel.loadCounts()
    PhoneConnectivity.shared.sendCountsToWatch()
    // ... rest of your code
}
```

---

## 🧪 Testing Your Integration

### **Test on Simulator**

1. **Build and Run** both iPhone and Watch simulators
2. **Increment Tesla count** on iPhone → Watch should update
3. **Increment Tesla count** on Watch → iPhone should update
4. **Increment CT count** on either device → Both should sync

### **Test on Real Device**

1. **Pair** your Apple Watch with iPhone
2. **Install** both apps
3. **Verify** bidirectional communication

---

## 🐛 Troubleshooting

### **Watch doesn't receive updates from iPhone**

- Check that App Groups capability is enabled on both targets
- Verify `WCSession.default.isReachable` returns true
- Check console logs for error messages
- Try force-closing both apps and reopening

### **iPhone doesn't receive updates from Watch**

- Verify Watch app is running
- Check network connectivity between devices
- Ensure WatchConnectivity protocol methods are implemented

### **"Cannot find 'TapCountViewModel' in scope"**

- Make sure `TapCountViewModel.swift` and `DailyCount.swift` are included in Watch app target
- Check target membership in File Inspector

---

## 📱 App Groups String

Replace `group.com.yourcompany.teslacounter` with:

```
group.com.mark-leonard.teslacounter
```

Or use whatever matches your app's bundle identifier pattern.

---

## 🎯 Summary of Changes

**iPhone App Changes:**
- ✅ Enhanced `PhoneConnectivity.swift` with bidirectional messaging
- ✅ Updated `TapCountViewModel.swift` to notify Watch on count changes
- ✅ Added App Groups capability

**New Watch App Files:**
- ✅ `WatchConnectivityManager.swift` (Watch side)
- ✅ `ContentView.swift` (Watch UI)
- ✅ Watch target configuration

**Data Flow:**
```
iPhone tap → TapCountViewModel.incrementCountForToday() 
         → PhoneConnectivity.updateWatch() 
         → WCSession.sendMessage() 
         → Watch receives → Updates display

Watch button → WatchConnectivityManager → sendActionToPhone()
           → WCSession.sendMessage()
           → iPhone receives → PhoneConnectivity processes
           → TapCountViewModel updates
           → Updates sent back to Watch
```

---

## 🚀 Next Steps

After setup:
1. Test on simulator
2. Test on real devices
3. Customize Watch UI styling (colors, fonts, etc.)
4. Consider adding more features (haptic feedback, complications, etc.)

Enjoy counting Teslas from your wrist! ⌚🚗
