# Logo Asset

## Required File
**File Name**: `logo.png`  
**Location**: `/assets/images/logo.png`  
**Dimensions**: 512×512 px (recommended)  
**Format**: PNG with transparency (alpha channel)

## Design Guidelines (Based on WeChat VI System)

### Visual Style
- **Shape**: Rounded square (24px corner radius) or circular
- **Background**: Transparent or WeChat Green gradient
- **Icon**: AI/Learning related symbol (brain, sparkle, book)
- **Style**: Minimalist, modern, friendly

### Color Palette (WeChat VI Standards)
```
Primary:   #07C160 (WeChat Green)
Gradient:  #09D46D → #07C160
Dark:      #06AE56
Text:      #111111 (Almost Black)
```

### Brand Elements
- **Brand Name**: Learnist.AI
- **Tagline**: Smart Learning, Real Understanding
- **Powered By**: Dr. Logic

### Fallback Behavior
If `logo.png` is missing, the app will display:
- WeChat Green gradient background
- White `Icons.auto_awesome` icon (Flutter Material)
- Dimensions: 120×120 px with 24px border radius

## Temporary Solution
Until the official logo is designed, the app uses the fallback icon with WeChat VI colors.

## Creating the Logo
1. Use design tools (Figma, Adobe Illustrator, Canva)
2. Export as PNG at 512×512 px
3. Save to `/assets/images/logo.png`
4. Run `flutter pub get` to refresh assets
5. Restart the app to see the logo

## Current Status
⚠️ **Logo file not found** - App is using fallback icon with WeChat Green gradient.

---

**Note**: The VI system colors have been updated from the old green (`#00A86B`) to WeChat Green (`#07C160`) for brand consistency.
