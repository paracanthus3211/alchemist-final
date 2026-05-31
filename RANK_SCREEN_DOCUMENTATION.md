# Rank Screen - Flutter Implementation

## Overview
Halaman Rank Screen untuk Flutter telah didesain ulang sepenuhnya untuk mencocokkan desain website dengan sempurna. Implementasi mencakup semua fitur yang diminta dengan animasi smooth dan responsive design.

## Fitur Utama

### 1. Header Section
- **Label**: "Laboratory Leaderboard" (uppercase, cyan color)
- **Title**: "Alchemy Rank" (28px, white, Space Grotesk font)
- Styling konsisten dengan website

### 2. Time Tabs
- **Options**: "This Week", "This Month", "All Time"
- **Active State**: Background teal light (#0d4a52) dengan text cyan
- **Inactive State**: Transparent background dengan text white 40% opacity
- **Behavior**: Smooth transition dengan AnimatedContainer
- **Functionality**: Reload data saat tab berubah

### 3. Scope Tabs
- **Options**: "Global", "Friend"
- **Active State**: Cyan text dengan underline 2px cyan di bawah
- **Inactive State**: White 40% opacity text
- **Behavior**: Smooth transition
- **Functionality**: Filter leaderboard berdasarkan scope

### 4. My Rank Card
- **Layout**: Horizontal card dengan rank badge di kiri dan content di kanan
- **Rank Badge**: 76x86px, menampilkan icon dari API atau default shield icon
- **Content**:
  - Username (uppercase, 22px, white)
  - Level dan chapter name (11px, white 70% opacity)
  - Current XP (22px, user's profile color)
- **Progress Bar**:
  - Background: white 15% opacity
  - Fill: user's profile color
  - Animated dengan smooth transition
- **Progress Text**: Menampilkan XP progress atau "Max Rank Achieved 🏆"
- **Styling**:
  - Background: teal light (#0d4a52)
  - 3D shadow effect (6px offset ke bawah)
  - Rounded corners 16px
  - Clickable untuk buka profile
- **Responsive**: Padding 24px, horizontal layout

### 5. Podium Section (Top 3)
- **Layout**: Stack dengan background stairs image
- **Rank 1 (Center)**:
  - Avatar: 80x80px dengan border lime (#B8F400)
  - Crown icon di atas
  - Glow effect dengan lime color
  - Padding bottom 190px
- **Rank 2 (Left)**:
  - Avatar: 70x70px dengan border purple (#d896ff)
  - Glow effect dengan purple color
  - Padding bottom 110px
- **Rank 3 (Right)**:
  - Avatar: 70x70px dengan border cyan (#00FBFF)
  - Glow effect dengan cyan color
  - Padding bottom 130px
- **Badge**: Hexagon gold badge dengan nomor rank
- **Info**: Username dan XP di bawah avatar
- **Animation**: FadeTransition saat load

### 6. Rank List (Rank 4+)
- **Container**: Dark background (#0c1112) dengan border white 8% opacity
- **Item Layout**:
  - Rank number (28px width, right-aligned)
  - Avatar (44x44px) dengan rank badge di bottom-right
  - User details (name, rank title)
  - XP (right-aligned, cyan color)
- **Highlight Current User**: Background teal light dengan cyan border
- **Hover Effect**: Background white 5% opacity
- **Clickable**: Buka profile user saat diklik
- **Animation**: SlideTransition dari bawah saat load

## Technical Implementation

### State Management
```dart
- _selectedPeriod: 'week' | 'month' | 'all'
- _selectedScope: 'global' | 'friends'
- _rankList: List<dynamic> (rank 4+)
- _top3: List<dynamic> (top 3 users)
- _currentUserRank: dynamic (current user's rank)
- _nextRank: dynamic (next rank to achieve)
- _currentUserXp: int
- _nextRankXp: int
- _isLoading: bool
```

### API Integration
```dart
// Get leaderboard data
final users = await api.getLeaderboard(
  period: _selectedPeriod,  // 'week', 'month', 'all'
  scope: _selectedScope,    // 'global', 'friends'
);

// Get all ranks
final ranks = await api.getRanks();

// Get current user
final currentUser = api.currentUser;
```

### Animations
- **FadeTransition**: Podium section fade in saat load
- **SlideTransition**: Rank list slide up dari bawah
- **AnimatedContainer**: Time tabs smooth transition
- **LinearProgressIndicator**: Progress bar animated fill

### Colors Used
```dart
static const Color _tealDark = Color(0xFF082d32);      // #082d32
static const Color _tealLight = Color(0xFF0d4a52);     // #0d4a52
static const Color _cyan = Color(0xFF00FBFF);          // #00FBFF
static const Color _lime = Color(0xFFB8F400);          // #B8F400
static const Color _purple = Color(0xFFd896ff);        // #d896ff
static const Color _gold = Color(0xFFFFD700);          // #FFD700
static const Color _bgCard = Color(0xFF1A2223);        // #1A2223
```

### Responsive Design
- **Padding**: 24px horizontal untuk main content
- **Flexible Layouts**: Menggunakan Expanded untuk responsive width
- **Safe Area**: Handled dengan BackgroundWrapper
- **Mobile First**: Dioptimalkan untuk mobile screens

## Error Handling
- **Network Errors**: Graceful fallback dengan empty state
- **Image Loading**: Fallback ke default icons jika image gagal load
- **Null Safety**: Proper null checking untuk semua dynamic data
- **Loading States**: Loading indicator saat fetch data

## Pull-to-Refresh
- **Gesture**: RefreshIndicator dengan BouncingScrollPhysics
- **Color**: Cyan (#00FBFF)
- **Background**: Card background color
- **Functionality**: Reload semua data saat refresh

## User Interactions
1. **Tab Switching**: Instant reload data dengan smooth animation
2. **Profile Navigation**: Tap pada user untuk buka profile
3. **My Rank Card**: Tap untuk buka current user profile
4. **Refresh**: Pull down untuk refresh leaderboard

## Performance Optimizations
- **Lazy Loading**: Data dimuat saat screen dibuka
- **Animation Controllers**: Proper disposal untuk prevent memory leaks
- **Image Caching**: Menggunakan cache-busting untuk avatar updates
- **Efficient Rebuilds**: setState hanya saat data berubah

## Browser/Website Parity
✅ Header dengan label dan title
✅ Time tabs dengan active state
✅ Scope tabs dengan underline active state
✅ My rank card dengan 3D shadow
✅ Podium section dengan top 3 users
✅ Rank list dengan rank badges
✅ Responsive design
✅ Smooth animations
✅ Proper error handling
✅ Pull-to-refresh support

## File Structure
```
lib/
├── rank_screen.dart          # Main rank screen implementation
├── services/
│   ├── api_service.dart      # API calls (getLeaderboard, getRanks)
│   └── settings_service.dart # Localization support
├── models/
│   └── user_model.dart       # User data model
└── widgets/
    └── background_wrapper.dart # Background styling
```

## Dependencies
- `flutter/material.dart` - UI framework
- `google_fonts` - Space Grotesk font
- `http` - API calls (via api_service)

## Future Enhancements
- [ ] Real-time leaderboard updates
- [ ] User search functionality
- [ ] Rank history/statistics
- [ ] Achievement badges display
- [ ] Custom rank colors per user
- [ ] Leaderboard filters (by level, chapter, etc.)

## Testing Checklist
- [x] Time tabs switching works correctly
- [x] Scope tabs switching works correctly
- [x] My rank card displays correct data
- [x] Podium shows top 3 users correctly
- [x] Rank list displays rank 4+ correctly
- [x] User profile navigation works
- [x] Pull-to-refresh works
- [x] Loading states display correctly
- [x] Error handling works
- [x] Responsive on mobile devices
- [x] Animations are smooth
- [x] Colors match website design

## Notes
- Semua warna menggunakan hex values yang sesuai dengan website
- Font menggunakan Space Grotesk untuk consistency
- Animations menggunakan TickerProviderStateMixin untuk smooth performance
- Proper null safety dengan null-aware operators
- Error handling dengan graceful fallbacks
