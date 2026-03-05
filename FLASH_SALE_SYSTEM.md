# Flash Sale System Documentation

## 📋 Table of Contents
- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Sale Cycle Timeline](#sale-cycle-timeline)
- [Key Components](#key-components)
- [Pricing Logic](#pricing-logic)
- [Visual Indicators](#visual-indicators)
- [User Experience Flow](#user-experience-flow)
- [Implementation Details](#implementation-details)
- [Configuration](#configuration)
- [Testing & Debugging](#testing--debugging)

---

## 🎯 Overview

The **Flash Sale System** is a dynamic, auto-looping promotional feature that creates urgency and engagement through limited-time offers. The system automatically cycles through three phases: countdown, active sale, and inactive periods, providing a continuous shopping experience with alternating discount strategies.

### Key Features
- ⏰ **Automatic Looping**: 80-second repeating cycle (5s countdown → 45s sale → 30s normal)
- 🔴 **Flash Discounts**: Extra 10-50% off during active sale periods
- 🟢 **Real Discounts**: API-based discounts shown during inactive periods
- 🎨 **Visual Feedback**: Color-coded badges, timers, and animated modals
- 🛒 **Cart Integration**: Smart price management with automatic updates
- 📱 **Real-time Updates**: All views update simultaneously when sale status changes

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      SaleManager                            │
│  (Singleton - Controls all sale timing and state)           │
│                                                              │
│  • currentPhase: SalePhase (.countdown/.active/.inactive)   │
│  • isSaleActive: Bool                                        │
│  • timeRemaining: TimeInterval                               │
│  • showSaleEndedModal: Bool                                  │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   │ Publishes changes via @Published
                   │
          ┌────────┴────────┐
          │                 │
          ▼                 ▼
┌──────────────────┐  ┌──────────────────┐
│  UIKit Views     │  │  SwiftUI Views   │
│                  │  │                  │
│ • ProductList    │  │ • HomeTabView    │
│ • ProductDetails │  │ • AllProductsView│
│ • TableViewCell  │  │ • ProductCard    │
└────────┬─────────┘  └────────┬─────────┘
         │                     │
         │                     │
         └─────────┬───────────┘
                   │
                   ▼
         ┌──────────────────┐
         │   CartManager    │
         │                  │
         │ • Manages items  │
         │ • Applies discnt │
         │ • Price updates  │
         └──────────────────┘
```

---

## ⏱️ Sale Cycle Timeline

The system operates on an **80-second loop** divided into three phases:

```
┌─────────────────────────────────────────────────────────────┐
│                    80-SECOND CYCLE                           │
├───────────┬──────────────────────┬─────────────────────────┤
│ COUNTDOWN │    FLASH SALE        │   NORMAL PERIOD         │
│  5 secs   │     45 secs          │    30 secs              │
├───────────┼──────────────────────┼─────────────────────────┤
│ Phase:    │ Phase:               │ Phase:                  │
│ .countdown│ .active              │ .inactive               │
│           │                      │                         │
│ Status:   │ Status:              │ Status:                 │
│ Sale OFF  │ Sale ON              │ Sale OFF                │
│           │                      │                         │
│ Action:   │ Action:              │ Action:                 │
│ • Prepare │ • Show banner (1.5s) │ • Show "ended" modal    │
│ • Wait    │ • Red badges         │ • Green badges          │
│           │ • Extra discounts    │ • Real API discounts    │
│           │ • Flash prices       │ • Regular prices        │
└───────────┴──────────────────────┴─────────────────────────┘
                                   │
                                   └──► Loop back to COUNTDOWN
```

### Phase Durations
```swift
private let countdownDuration: TimeInterval = 5      // 5 seconds
private let activeDuration: TimeInterval = 45        // 45 seconds  
private let inactiveDuration: TimeInterval = 30      // 30 seconds
```

---

## 🔧 Key Components

### 1. **SaleManager** (`SaleManager.swift`)
**Role**: Singleton that orchestrates the entire sale cycle

```swift
class SaleManager: ObservableObject {
    static let shared = SaleManager()
    
    @Published var isSaleActive: Bool
    @Published var currentPhase: SalePhase
    @Published var timeRemaining: TimeInterval
    @Published var showSaleEndedModal: Bool
}
```

**Responsibilities**:
- Manages phase transitions automatically
- Publishes state changes to all observers
- Triggers cart discount clearing when sale ends
- Provides formatted time remaining
- Handles phase descriptions for UI

**Key Methods**:
- `startCountdown()` - Begins 5-second countdown phase
- `startFlashSale()` - Activates 45-second flash sale
- `startNormalPeriod()` - Begins 30-second normal pricing
- `formattedTimeRemaining()` - Returns "MM:SS" format
- `skipToNextPhase()` - Debug/testing helper

---

### 2. **Product Model** (`Product.swift`)
**Role**: Defines product structure and discount calculation

```swift
struct Product: Codable, Identifiable {
    let id: Int
    let title: String
    let price: Double              // API price (already discounted)
    let discountPercentage: Double? // Real API discount %
    let thumbnail: String?
    // ... other properties
}

struct DiscountInfo {
    let discountPercentage: Double
    let badgeLabel: String
    let tag: String?
}

func fakeDiscount(for product: Product) -> DiscountInfo {
    // Deterministic fake discount: 10%, 15%, 20%, 25%, 30%, 35%, 40%, 50%
    // Based on product.id for consistency
}
```

**Important**: 
- API `price` is the **already-discounted price**
- API `discountPercentage` is the **real discount applied**
- `fakeDiscount()` generates **additional flash sale discount**

---

### 3. **CartManager** (`CartManager.swift`)
**Role**: Manages cart items and pricing logic

```swift
class CartManager: ObservableObject {
    static let shared = CartManager()
    
    @Published var items: [CartItem] = []
    
    func add(product: Product, discountInfo: DiscountInfo?)
    func clearDiscounts() // Called when sale ends
}
```

**Price Calculation Logic**:

```swift
// DURING FLASH SALE (isSaleActive = true)
finalPrice = apiPrice × (1 - fakeDiscount/100)
originalPrice = apiPrice  // Store API price as "original"

// AFTER FLASH SALE (isSaleActive = false, has real discount)
finalPrice = apiPrice  // Use as-is
originalPrice = apiPrice ÷ (1 - realDiscount/100)  // Calculate backwards

// NO DISCOUNT
finalPrice = apiPrice
originalPrice = nil
```

---

### 4. **ProductListTableViewCell** (`ProductListTableViewCell.swift`)
**Role**: UIKit cell displaying product with sale-aware pricing

**Display Logic**:
```swift
if isSaleActive {
    // FLASH SALE MODE
    let fakeDiscountInfo = fakeDiscount(for: product)
    if fakeDiscountInfo.discountPercentage >= 10.0 {
        discountedPrice = product.price × (1 - discount/100)
        // Show: discountedPrice (green) | product.price (strikethrough)
        // Badge: RED with fake discount %
    }
} else {
    // REGULAR MODE
    if let realDiscount = product.discountPercentage, realDiscount >= 10.0 {
        calculatedOriginalPrice = product.price ÷ (1 - realDiscount/100)
        // Show: product.price (green) | calculatedOriginal (strikethrough)
        // Badge: GREEN with real discount %
    }
}
```

---

### 5. **DiscountModalView** (`DiscountModalView.swift`)
**Role**: Auto-showing promotional banner

```swift
class DiscountModalManager: ObservableObject {
    @Published var isVisible: Bool = false
    private var hasShownForCurrentCycle = false
}
```

**Trigger Logic**:
- Observes `SaleManager.shared.$currentPhase`
- Shows banner 1.5 seconds after sale becomes `.active`
- Resets `hasShownForCurrentCycle` when sale becomes `.inactive`
- Ensures banner appears **once per sale cycle**

**Banner Content**:
- First 5 seconds of sale: "IT'S BACK!" + "Flash sale is now active!"
- Rest of sale: "Up to 50% OFF" + "on selected items today only"
- Live countdown timer showing time remaining

---

### 6. **SaleEndedModalView** (`SaleEndedModalView.swift`)
**Role**: Notification when flash sale ends

**Trigger**: 
- Appears 0.5s after `isSaleActive` changes from `true` to `false`
- Managed by `SaleManager.shared.showSaleEndedModal`

**Message**:
```
"Flash Sale Ended"
"The flash sale will return soon!"
"All items have been updated to regular pricing with real discounts"
```

---

## 💰 Pricing Logic

### Example Product: Price = $50, API Discount = 15%

#### Scenario A: Flash Sale Active (45 seconds)
- **Fake discount assigned**: 30% (from `fakeDiscount()`)
- **Displayed price**: $50 × 0.70 = **$35.00** (green, bold)
- **Strikethrough price**: $50.00 (gray)
- **Badge**: 🔴 **"30% OFF"** (red background)
- **Cart price**: $35.00 with flash discount metadata

#### Scenario B: Normal Period (30 seconds)
- **Real discount used**: 15% (from API)
- **Displayed price**: **$50.00** (green, bold) ← API price as-is
- **Strikethrough price**: $50 ÷ 0.85 = $58.82 (gray)
- **Badge**: 🟢 **"15% OFF"** (green background)
- **Cart price**: $50.00 with real discount metadata

#### Scenario C: No Discount
- **Displayed price**: **$50.00** (standard color)
- **No strikethrough**
- **No badge**

---

## 🎨 Visual Indicators

### Badge Colors

| Phase | Badge Color | Hex Code | Meaning |
|-------|-------------|----------|---------|
| Flash Sale | 🔴 Red | `#E02E2E` (0.88, 0.18, 0.18) | Extra flash discount |
| Normal | 🟢 Green | `#1BAE75` (0.10, 0.68, 0.46) | Real API discount |
| No Discount | — | — | No badge shown |

### UI Elements

```
┌─────────────────────────────────────────┐
│  FLASH SALE (RED BADGE)                │
│  iPhone 15 Pro                          │
│  📱 Electronics                         │
│                                         │
│  $ 999.00  $ 1,199.00                  │
│  └─green    └─strikethrough            │
│                                         │
│  [30% OFF] ← RED badge                 │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  NORMAL PERIOD (GREEN BADGE)           │
│  iPhone 15 Pro                          │
│  📱 Electronics                         │
│                                         │
│  $ 1,199.00  $ 1,331.11                │
│  └─green      └─strikethrough          │
│                                         │
│  [13% OFF] ← GREEN badge               │
└─────────────────────────────────────────┘
```

---

## 👤 User Experience Flow

### Complete User Journey

```
1. USER OPENS APP
   └─> Countdown phase (5s)
       └─> Sees "Flash Sale Coming Soon" with timer

2. COUNTDOWN ENDS → SALE STARTS
   └─> Banner pops up: "IT'S BACK!" 
   └─> All products show RED badges with flash discounts
   └─> Prices drop with extra savings
   └─> Timer shows 00:45 counting down

3. USER ADDS ITEMS TO CART (During Sale)
   └─> Flash-discounted prices saved
   └─> Red badges visible in cart
   └─> Original (API) price shown as comparison

4. SALE ENDS (After 45s)
   └─> "Flash Sale Ended" modal appears
   └─> Cart prices automatically updated
   └─> All views refresh with GREEN badges
   └─> Real API discounts now shown

5. NORMAL PERIOD (30s)
   └─> Products show real discounts
   └─> Green badges displayed
   └─> Calculated original prices shown
   └─> "Sale Coming Soon" countdown begins

6. CYCLE REPEATS
   └─> System loops back to step 2 infinitely
```

---

## 🔍 Implementation Details

### File Structure
```
iOSTraining/
├── Helpers/
│   └── SaleManager.swift              # Core sale cycle engine
│
├── Features/
│   ├── Product List/
│   │   ├── Model/
│   │   │   └── Product.swift          # Product & DiscountInfo definitions
│   │   ├── ProductListViewController.swift
│   │   ├── ProductListTableViewCell.swift
│   │   └── Product Details/
│   │       └── ProductDetailViewController.swift
│   │
│   ├── Home/
│   │   ├── HomeTabView.swift          # Main SwiftUI home screen
│   │   ├── AllProductsView.swift      # Sale/normal product grids
│   │   ├── DiscountModalView.swift    # Auto-showing banner
│   │   └── SaleEndedModalView.swift   # End notification
│   │
│   └── Cart/
│       ├── Model/
│       │   ├── CartManager.swift      # Cart logic & pricing
│       │   └── CartItem.swift         # Cart item model
│       └── Cart.swift                 # Cart UI
```

### Combine Publishers

All views observe `SaleManager` using Combine:

```swift
// UIKit (ProductListViewController.swift)
private var saleCancellable: AnyCancellable?

saleCancellable = SaleManager.shared.$isSaleActive
    .sink { [weak self] _ in
        DispatchQueue.main.async {
            self?.tableView.reloadData()
        }
    }

// SwiftUI (HomeTabView.swift)
@StateObject private var saleManager = SaleManager.shared

// Automatically updates when @Published properties change
```

### Phase Transition Flow

```swift
private func transitionToNextPhase() {
    switch currentPhase {
    case .countdown:
        startFlashSale()
        // • Sets isSaleActive = true
        // • Posts "SaleStarted" notification
        // • DiscountModalManager shows banner
        
    case .active:
        startNormalPeriod()
        onSaleEnded()
        // • Sets isSaleActive = false
        // • Calls CartManager.clearDiscounts()
        // • Shows sale ended modal
        // • All views update to green badges
        
    case .inactive:
        startCountdown()
        // • Resets for next cycle
        // • DiscountModalManager resets flag
    }
}
```

---

## ⚙️ Configuration

### Adjusting Phase Durations

Edit `SaleManager.swift`:

```swift
class SaleManager: ObservableObject {
    // Modify these values to change timing
    private let countdownDuration: TimeInterval = 5    // Default: 5s
    private let activeDuration: TimeInterval = 45      // Default: 45s
    private let inactiveDuration: TimeInterval = 30    // Default: 30s
}
```

### Customizing Fake Discounts

Edit `Product.swift`:

```swift
func fakeDiscount(for product: Product) -> DiscountInfo {
    let seed = abs(product.id)
    
    // Modify discount percentages here
    let percents = [10, 15, 20, 25, 30, 35, 40, 50]
    
    // Modify tags here
    let tags: [String?] = ["Best Seller", "Hot 🔥", "Top Pick", 
                           nil, nil, "Limited", nil, "Popular"]
    
    let pct = percents[seed % percents.count]
    let tag = tags[seed % tags.count]
    return DiscountInfo(discountPercentage: Double(pct), 
                       badgeLabel: "\(pct)% OFF", 
                       tag: tag)
}
```

### Changing Badge Colors

#### Red Flash Sale Badge
```swift
// In ProductListTableViewCell.swift
productIsFeatured.backgroundColor = UIColor(red: 0.88, green: 0.18, blue: 0.18, alpha: 1.0)
```

#### Green Regular Badge
```swift
// In ProductListTableViewCell.swift  
productIsFeatured.backgroundColor = UIColor(red: 0.10, green: 0.68, blue: 0.46, alpha: 1.0)
```

### Minimum Discount Threshold

Products only show badges if discount ≥ 10%:

```swift
// Change the 10.0 value to adjust threshold
if isSaleActive, fakeDiscountInfo.discountPercentage >= 10.0 {
    // Show badge
}

if let realDiscount = product.discountPercentage, realDiscount >= 10.0 {
    // Show badge  
}
```

---

## 🧪 Testing & Debugging

### Debug Methods

```swift
// In SaleManager.swift

// Skip to next phase immediately
SaleManager.shared.skipToNextPhase()

// Reset to countdown phase
SaleManager.shared.resetCycle()

// Check current state
print("Phase: \(SaleManager.shared.currentPhase)")
print("Active: \(SaleManager.shared.isSaleActive)")
print("Time: \(SaleManager.shared.formattedTimeRemaining())")
```

### Console Logging

The system logs phase transitions:

```
⏱️ Flash sale starting in 5 seconds...
🔥 FLASH SALE STARTED! (45 seconds)
✅ Normal period - Real discounts active (30 seconds)
🔴 Flash sale ended! Clearing flash discounts...
⏱️ Flash sale starting in 5 seconds...
```

### Manual Banner Trigger

```swift
// In DiscountModalManager
DiscountModalManager().showNow()
```

### Checking Cart Price Logic

```swift
// Add breakpoint in CartManager.add(product:discountInfo:)
// Verify:
// 1. isSaleActive matches expected phase
// 2. discountPct is correct value
// 3. finalPrice calculation is accurate
// 4. originalPrice is properly set/nil
```

### Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Badge not showing | Discount < 10% | Lower threshold or check product data |
| Wrong price in cart | Phase mismatch | Ensure SaleManager.shared is observed |
| Banner not appearing | Flag not reset | Check `hasShownForCurrentCycle` logic |
| Timer not updating | Combine not connected | Verify @StateObject/@ObservedObject |
| Colors not changing | Sale status cached | Force reload on phase change |

---

## 📊 Performance Considerations

### Timer Efficiency
- Uses **single shared timer** in SaleManager
- All views observe published properties (no individual timers)
- 1-second update interval (not every frame)

### Memory Management
- Singleton pattern prevents multiple instances
- Weak self references in closures prevent retain cycles
- AnyCancellable auto-cleanup on deinit

### UI Updates
- Throttled to phase transitions (not continuous)
- Table/collection views reload only on phase change
- SwiftUI views auto-update via @Published

---

## 🎓 Key Concepts

### Why Calculate Original Price Backwards?

The API provides **already-discounted prices**:
- API Price: $50 (after 15% discount)
- Real Original: $58.82

We calculate: `$50 ÷ (1 - 0.15) = $58.82`

This shows users the "before discount" price without storing it separately.

### Why Fake Discounts Are Deterministic

Using `product.id` as seed ensures:
- Same product always gets same fake discount
- Discount stays consistent across app launches
- Users see same deals if they return during sale
- No need to store fake discounts in database

### Why Three Phases?

1. **Countdown (5s)**: Builds anticipation, gives users context
2. **Active (45s)**: Long enough to browse, short enough to create urgency
3. **Inactive (30s)**: "Breather" period, maintains real discounts, prevents fatigue

---

## 📝 Notes

### Design Decisions

1. **Auto-looping vs Manual**: Automatic creates continuous engagement without admin intervention
2. **Red vs Green badges**: Clear visual distinction between flash and regular discounts
3. **Banner on every cycle**: Reminds users sale is back, drives repeated engagement
4. **Cart price updates**: Maintains fairness, prevents confusion if sale ends mid-checkout
5. **Real discounts shown**: Keeps value proposition even during normal periods

### Future Enhancements

Potential improvements:
- [ ] Notification when sale starts (push/local)
- [ ] Analytics tracking (conversion by phase)
- [ ] A/B testing different durations
- [ ] Personalized fake discount percentages
- [ ] Exclude certain categories from flash sales
- [ ] Admin panel to pause/modify cycle
- [ ] Multiple concurrent sales (category-specific)
- [ ] Progressive discount (increases over time)

---

## 📱 Supported Views

### ✅ Fully Integrated
- [x] **HomeTabView** (SwiftUI) - Main home screen with sale tab
- [x] **AllProductsView** (SwiftUI) - Sale/normal product grids
- [x] **ProductListViewController** (UIKit) - Products tab
- [x] **ProductListTableViewCell** (UIKit) - Product cell with badges
- [x] **ProductDetailViewController** (UIKit) - Product details
- [x] **Cart** (SwiftUI) - Cart with price display
- [x] **DiscountModalView** (SwiftUI) - Auto-banner
- [x] **SaleEndedModalView** (SwiftUI) - End notification

### Phase-Aware Components
All views automatically update via Combine publishers:
- Badge colors change (red ↔ green)
- Prices recalculate instantly  
- Timers update every second
- Modals appear/dismiss automatically

---

## 🚀 Quick Start Guide

### For Developers

1. **Understanding the cycle**: Review [Sale Cycle Timeline](#sale-cycle-timeline)
2. **Key file**: Start with `SaleManager.swift` to understand the engine
3. **Price logic**: Read [Pricing Logic](#pricing-logic) section carefully
4. **Customization**: Adjust durations in [Configuration](#configuration)
5. **Testing**: Use debug methods from [Testing & Debugging](#testing--debugging)

### For Designers

- Badge colors defined in [Visual Indicators](#visual-indicators)
- UI mockups align with [User Experience Flow](#user-experience-flow)
- Timing considerations in [Sale Cycle Timeline](#sale-cycle-timeline)

### For QA

- Test all phases: countdown → active → inactive → repeat
- Verify cart price updates on phase transitions
- Check banner appears once per sale cycle
- Confirm badge colors match phase (red/green)
- Validate timer accuracy (compare to device clock)

---

## 📞 Support

For questions or issues:
1. Check [Common Issues](#common-issues--solutions)
2. Review console logs for phase transitions
3. Use debug methods to inspect state
4. Verify Combine publishers are connected

---

## 📄 License

Internal documentation for iOSTraining project.

---

**Last Updated**: March 5, 2026  
**Version**: 1.0  
**Author**: iOS Training Team
