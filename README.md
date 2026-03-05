# iOS E-Commerce Training App

A feature-rich iOS e-commerce application built as a training project, showcasing modern iOS development practices with a sophisticated flash sale system, shopping cart, checkout process, and user management.

## 📱 Overview

This application demonstrates a complete e-commerce experience with:
- **Dynamic Flash Sales** - Automated 80-second sale cycles with countdown timers
- **Product Browsing** - Browse and search through 200+ products from DummyJSON API
- **Shopping Cart** - Add, update, and manage cart items with real-time price calculations
- **Checkout Process** - Complete order flow with address validation and order confirmation
- **User Features** - Authentication, wishlist, order history, and settings management
- **Hybrid Architecture** - Combines UIKit and SwiftUI for optimal performance and modern UI

## ✨ Key Features

### 🔥 Flash Sale System
- **Automatic Looping**: 80-second repeating cycle
  - 5 seconds: Countdown phase with anticipation banner
  - 45 seconds: Active flash sale with extra 10-50% discounts
  - 30 seconds: Normal period with API-based discounts
- **Real-time Updates**: All views update simultaneously across the app
- **Visual Feedback**: Color-coded badges, animated timers, and modal notifications
- **Smart Pricing**: Automatic price adjustments in cart during sale transitions

### 🛒 Shopping Experience
- **Product List**: UIKit-based table view with custom cells
- **Product Details**: Detailed product information with images and specifications
- **All Products View**: SwiftUI grid layout with search and filtering
- **Cart Management**: Add/remove items, quantity updates, price calculations
- **Wishlist**: Save favorite products for later
- **Orders**: View past order history and details

### 💳 Checkout & Orders
- **Address Form**: Validated shipping information input
- **Order Summary**: Review items and total before confirmation
- **Order Success**: Confirmation screen with order details
- **Order History**: Track all completed purchases

### 👤 User Management
- **Sign In**: User authentication with email/password
- **Settings**: User profile management and app preferences
- **Persistent State**: UserDefaults for user session management

## 🏗️ Architecture

### Design Pattern
- **MVVM (Model-View-ViewModel)** pattern for business logic separation
- **Singleton Pattern** for shared managers (SaleManager, NetworkManager, CartManager)
- **Delegate Pattern** for network callbacks
- **Combine Framework** for reactive state management

### Project Structure
```
iOSTraining/
├── Features/                    # Feature modules
│   ├── Cart/                   # Shopping cart functionality
│   │   ├── Model/
│   │   ├── ViewModel/
│   │   └── Views (SwiftUI)
│   ├── Checkout/               # Checkout flow
│   │   ├── AddressFormView.swift
│   │   ├── Checkout.swift
│   │   └── OrderSuccessView.swift
│   ├── Home/                   # Home dashboard
│   │   ├── HomeView.swift
│   │   ├── HomeTabView.swift
│   │   ├── AllProductsView.swift
│   │   └── ViewModel/
│   ├── Product List/           # Product browsing (UIKit)
│   │   ├── ProductListViewController
│   │   ├── ProductListTableViewCell
│   │   └── Product Details/
│   ├── Orders/                 # Order history
│   ├── Wishlist/               # Saved products
│   ├── Settings/               # User settings
│   └── Sign in/                # Authentication
├── Helpers/                    # Shared utilities
│   ├── NetworkManager.swift    # API communication
│   ├── SaleManager.swift       # Flash sale logic
│   └── Extensions/
│       └── ColorExtensions.swift
├── Assets.xcassets/            # App images and icons
├── AppDelegate.swift
└── SceneDelegate.swift
```

## 🛠️ Technical Stack

### Frameworks & Technologies
- **UIKit** - Product list, product details, sign-in screens
- **SwiftUI** - Modern views (Home, Cart, Checkout, Wishlist, Orders)
- **Combine** - Reactive programming for state management
- **URLSession** - Network requests
- **UserDefaults** - Local data persistence
- **Codable** - JSON parsing
- **Auto Layout** - Responsive UI design

### iOS Version
- **Minimum Deployment Target**: iOS 14.0+
- **Language**: Swift 5

### External API
- **DummyJSON API**: `https://dummyjson.com/products?limit=200`
  - Provides product data (title, price, description, images, ratings, etc.)

## 📋 Requirements

- Xcode 13.0 or later
- iOS 14.0 or later
- Swift 5.0 or later
- macOS 11.0 or later (for development)

## 🚀 Getting Started

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd iOSTraining
   ```

2. **Open the project**
   ```bash
   open iOSTraining.xcodeproj
   ```

3. **Select a simulator or device**
   - Choose your target device from the Xcode toolbar

4. **Build and Run**
   - Press `Cmd + R` or click the Play button
   - The app will build and launch automatically

### First Launch
- The app will fetch products from DummyJSON API on first launch
- Sign in screen will appear - create an account or use test credentials
- Flash sale cycles start automatically upon app launch

## 📱 App Modules

### 1. Sign In
- Email and password authentication
- User session management with UserDefaults
- Validation and error handling

### 2. Home Dashboard
- Welcome section with user greeting
- Promotional cards (Summer Sale, New Arrivals, Flash Deals)
- Category navigation (Electronics, Fashion, Home, Beauty)
- Featured products grid
- Flash sale banner with countdown timer
- Navigation to all products view

### 3. Product Browsing
- **ProductListViewController** (UIKit): Table view with custom cells
- **AllProductsView** (SwiftUI): Grid layout with search
- Product images, titles, prices, and ratings
- Sale badges (Flash/Real discounts)
- Real-time price updates during sales

### 4. Product Details
- Full product information
- Image gallery
- Price with discount calculations
- Add to cart functionality
- Add to wishlist option
- Stock and brand information

### 5. Shopping Cart
- Cart item list with images and prices
- Quantity adjustment (increment/decrement)
- Remove items functionality
- Subtotal calculation
- Flash sale price indicators
- Proceed to checkout button

### 6. Checkout
- Address form with validation
- Order summary review
- Total price calculation
- Place order functionality
- Order success confirmation screen

### 7. Orders
- Order history list
- Order details view
- Order status tracking
- Date and total information

### 8. Wishlist
- Saved products list
- Quick add to cart from wishlist
- Remove from wishlist option

### 9. Settings
- User profile information
- App preferences
- Account management
- Sign out functionality

## ⚙️ Flash Sale System Details

The flash sale system is the core feature of this app, providing dynamic pricing and urgency-driven user engagement.

### Sale Cycle (80 seconds)
```
┌─────────────────────────────────────────────────┐
│  COUNTDOWN → FLASH SALE → NORMAL → [repeat]    │
│   (5s)         (45s)       (30s)                │
└─────────────────────────────────────────────────┘
```

### Phases

#### 1. Countdown Phase (5 seconds)
- Displays "Flash sale starting in X seconds" banner
- Prepares users for incoming sale
- Shows normal prices with API discounts

#### 2. Active Phase (45 seconds)
- **Flash Sale Banner**: Prominent red banner with timer
- **Extra Discounts**: Additional 10-50% off on top of regular discounts
- **Red Badges**: "🔴 FLASH -XX%" badges on products
- **Cart Integration**: Flash prices applied to cart items
- **Opening Animation**: 1.5-second entrance animation

#### 3. Inactive Phase (30 seconds)
- **Normal Pricing**: API-based regular discounts only
- **Green Badges**: "🟢 -XX% Real" badges showing actual discounts
- **Sale Ended Modal**: Shows when transitioning from active to inactive
- **Regular Experience**: Standard shopping without flash incentives

### SaleManager Components

```swift
// Key Published Properties
@Published var isSaleActive: Bool
@Published var currentPhase: SalePhase
@Published var showSaleEndedModal: Bool
@Published var timeRemaining: TimeInterval

// Phase Enum
enum SalePhase {
    case countdown   // 5 seconds
    case active      // 45 seconds
    case inactive    // 30 seconds
}
```

### Price Calculation Logic

```swift
// During Flash Sale (Active Phase)
if saleManager.isSaleActive {
    let flashDiscount = product.baseDiscount + flashExtraDiscount
    displayPrice = originalPrice * (1 - flashDiscount/100)
    badge = "🔴 FLASH -\(flashDiscount)%"
}

// During Normal Period (Inactive/Countdown Phase)
else if product.discountPercentage > 0 {
    displayPrice = originalPrice * (1 - product.discountPercentage/100)
    badge = "🟢 -\(product.discountPercentage)% Real"
}
```

## 🎨 UI Components

### UIKit Views
- **ProductListTableViewCell**: Custom table view cell with XIB
- **ProductListViewController**: Product list with search and filtering
- **ProductDetailViewController**: Detailed product view
- **SigninViewController**: Login screen with form validation

### SwiftUI Views
- **HomeView**: Dashboard with promo cards and categories
- **HomeTabView**: Bottom tab navigation
- **AllProductsView**: Product grid with flash sale indicators
- **Cart**: Shopping cart with item management
- **Checkout**: Multi-step checkout flow
- **OrdersView**: Order history list
- **WishlistView**: Saved products
- **SettingsView**: User preferences

### Reusable Components
- **DiscountModalView**: Flash sale announcement popup
- **SaleEndedModalView**: Sale ended notification
- **CartRowView**: Individual cart item row
- **CartItemModal**: Cart action sheet

## 🔄 State Management

### SaleManager (Singleton)
- Manages flash sale timing and phases
- Publishes state changes via Combine `@Published` properties
- Observed by all views needing sale status

### NetworkManager (Singleton)
- Handles API requests
- Delegate pattern for response callbacks
- Fetches product data from DummyJSON

### ViewModels
- **HomeViewModel**: Home screen business logic
- **CartViewModel**: Cart operations and calculations
- **CheckoutViewModel**: Order processing logic
- **ProductViewModel**: Product data management

## 📊 Data Models

### Core Models
```swift
struct Product: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let discountPercentage: Double
    let rating: Double
    let stock: Int
    let brand: String?
    let category: String
    let thumbnail: String
    let images: [String]
}

struct CartItem {
    let product: Product
    var quantity: Int
    var isPurchased: Bool
}

struct Order {
    let id: UUID
    let items: [CartItem]
    let total: Double
    let date: Date
    let shippingAddress: Address
}
```

## 🧪 Testing & Development

### Debugging Flash Sales
1. Observe console logs for phase transitions:
   ```
   ⏱️ Flash sale starting in 5 seconds...
   🔥 FLASH SALE IS NOW ACTIVE! (45 seconds)
   ⏹️ Flash sale ended. Normal period starts. (30 seconds)
   ```

2. Adjust phase durations in `SaleManager.swift`:
   ```swift
   private let countdownDuration: TimeInterval = 5
   private let activeDuration: TimeInterval = 45
   private let inactiveDuration: TimeInterval = 30
   ```

### Network Debugging
- Check `NetworkManager` delegate methods for API responses
- Verify product data structure matches API response
- Monitor network calls in Console

### Common Development Tasks

#### Modify Sale Timing
Edit `SaleManager.swift` phase durations to test different cycles.

#### Add New Products
The app automatically fetches products from DummyJSON API. To use a different source, update the URL in `NetworkManager.swift`.

#### Customize Flash Discounts
Modify the flash discount calculation logic in views that display prices.

#### Change Color Scheme
Edit colors in `ColorExtensions.swift` or SwiftUI views directly.

## 📝 Configuration

### UserDefaults Keys
- `userName`: Stored user name
- `userEmail`: Stored user email
- `isLoggedIn`: Authentication state
- `cartItems`: Serialized cart data
- `wishlistItems`: Serialized wishlist data

### Asset Catalog
- App icons in multiple sizes
- Product category icons
- Social media login icons (Facebook, Google, Spotify)
- Placeholder images (person1, person2)

## 🤝 Contributing

This is a training project for learning iOS development. Key learning objectives:

1. **UIKit & SwiftUI Integration**: Understanding both frameworks
2. **MVVM Architecture**: Separation of concerns and testability
3. **Networking**: API integration with URLSession
4. **State Management**: Combine framework and @Published properties
5. **Timer-based Logic**: Creating time-sensitive features
6. **Custom UI Components**: Building reusable views
7. **Data Persistence**: UserDefaults for local storage
8. **Navigation**: Programmatic and declarative navigation

## 📖 Documentation

For detailed information about the Flash Sale System, refer to:
- **[FLASH_SALE_SYSTEM.md](FLASH_SALE_SYSTEM.md)** - Comprehensive flash sale documentation

## 🐛 Known Issues & Future Enhancements

### Potential Improvements
- [ ] Add Core Data for persistent storage
- [ ] Implement actual payment gateway integration
- [ ] Add push notifications for flash sale start
- [ ] Implement product reviews and ratings
- [ ] Add social sharing features
- [ ] Create admin panel for product management
- [ ] Add animations and transitions
- [ ] Implement search with filters and sorting
- [ ] Add product recommendations
- [ ] Implement real-time inventory management

## 📄 License

This project is created for educational purposes as part of iOS training.

## 👥 Credits

- **API**: [DummyJSON](https://dummyjson.com) for product data
- **Project**: iOS Training Exercise
- **Created**: February-March 2026

## 📧 Contact

For questions or feedback regarding this training project, please reach out to the development team.

---

**Happy Shopping! 🛍️**
