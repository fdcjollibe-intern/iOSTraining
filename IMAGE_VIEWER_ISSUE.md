# Image Not Displaying in Full-Screen Viewer

## Problem Summary
After implementing the `ImageViewerViewController` for full-screen image viewing with pinch zoom and swipe gestures, the images are not showing when the collection view cell is tapped in `ProductDetailViewController`.

## Current Implementation

### What's Working
- Tab bar navigation (Home, Shop, Trend, Favorites, Settings)
- Product list view in Shop tab
- Product detail view with image carousel
- Image navigation via swipe gestures in detail view
- Page control updates correctly
- Tap detection on collection view cells (the full-screen modal appears)

### What's Not Working
- Images not displaying in the `ImageViewerViewController`
- The full-screen viewer shows black screen with close button, but no image

## Potential Issues to Investigate

### 1. Image Loading Method
- How are images being loaded in `ProductImageCollectionViewCell`?
- Is `imageName` a string reference to an asset, URL, or file path?
- Does the loading mechanism differ between the cell and the full-screen viewer?

### 2. Product Model Structure
- What type is `product.image` (array of strings, URLs, or image names)?
- Are the image references valid for `UIImage(named:)`?

### 3. Image Asset Location
- Are images in Assets.xcassets or bundled files?
- Correct naming convention being used?

## Current Code Structure

### ProductImageCollectionViewCell.swift
```swift
var imageName: String? {
    didSet {
        displayImage()
    }
}

private func displayImage() {
    photoImageCollection.image = UIImage(named: imageName ?? "")
}
```

### ImageViewerViewController.swift
```swift
private func displayImage(at index: Int) {
    guard index >= 0 && index < images.count else { return }
    
    let imageName = images[index]
    imageView.image = UIImage(named: imageName)
    imageView.frame = CGRect(origin: .zero, size: view.bounds.size)
    scrollView.contentSize = imageView.bounds.size
    scrollView.zoomScale = 1.0
}
```

### Sample Product Data
```swift
Product(image: ["L5Pro", "RG16", "ZG14", "ZG16"],
        name: "Lenovo Legion 5 Pro R9000P 2025",
        ...)
```

## Diagnosis Steps

### Step 1: Verify Image Loading in Collection View
- Check if images display correctly in the `ProductImageCollectionViewCell`
- Confirm that `UIImage(named:)` works for these image names

### Step 2: Debug Image Viewer Initialization
Add debug logging to `displayImage(at:)`:
```swift
private func displayImage(at index: Int) {
    guard index >= 0 && index < images.count else { return }
    
    let imageName = images[index]
    print("🖼️ Loading image: \(imageName)")
    
    if let image = UIImage(named: imageName) {
        print("✅ Image loaded successfully: \(image.size)")
        imageView.image = image
    } else {
        print("❌ Failed to load image: \(imageName)")
    }
    
    imageView.frame = CGRect(origin: .zero, size: view.bounds.size)
    scrollView.contentSize = imageView.bounds.size
    scrollView.zoomScale = 1.0
}
```

### Step 3: Check Image Frame Setup
The issue might be with how the `imageView.frame` is set. Try this alternative:
```swift
private func displayImage(at index: Int) {
    guard index >= 0 && index < images.count else { return }
    
    let imageName = images[index]
    guard let image = UIImage(named: imageName) else {
        print("❌ Image not found: \(imageName)")
        return
    }
    
    imageView.image = image
    
    // Calculate proper frame for image
    let imageSize = image.size
    let screenSize = view.bounds.size
    
    let widthRatio = screenSize.width / imageSize.width
    let heightRatio = screenSize.height / imageSize.height
    let scale = min(widthRatio, heightRatio)
    
    let scaledWidth = imageSize.width * scale
    let scaledHeight = imageSize.height * scale
    
    imageView.frame = CGRect(x: (screenSize.width - scaledWidth) / 2,
                            y: (screenSize.height - scaledHeight) / 2,
                            width: scaledWidth,
                            height: scaledHeight)
    
    scrollView.contentSize = imageView.frame.size
    scrollView.zoomScale = 1.0
}
```

## Possible Solutions

### Solution 1: Fix Image Frame Sizing
The current implementation sets `imageView.frame` to `view.bounds.size`, which might cause layout issues. Update to properly size based on image dimensions.

### Solution 2: Ensure Image View is Visible
Add background color temporarily to debug visibility:
```swift
private func setupImageView() {
    imageView.contentMode = .scaleAspectFit
    imageView.isUserInteractionEnabled = true
    imageView.backgroundColor = .red // Debug: see if view is visible
    scrollView.addSubview(imageView)
}
```

### Solution 3: Check Asset Names
Verify that image names in the Product model match exactly with assets in Assets.xcassets:
- Case sensitivity matters
- No file extensions should be included
- Check for typos

## Next Steps

1. Add debug logging to `displayImage(at:)` method
2. Run the app and tap on an image
3. Check console output for error messages
4. Verify image names in Assets.xcassets match the array values
5. Test with a single known-working image name first

## Related Files
- `ImageViewerViewController.swift` - Full-screen image viewer
- `ProductDetailViewController.swift` - Product detail with image carousel
- `ProductImageCollectionViewCell.swift` - Collection view cell for images
- `Product.swift` - Product model with image array
- `Assets.xcassets/Products/` - Image assets location

## Status
🔴 **UNRESOLVED** - Images not displaying in full-screen viewer

Last Updated: February 27, 2026
