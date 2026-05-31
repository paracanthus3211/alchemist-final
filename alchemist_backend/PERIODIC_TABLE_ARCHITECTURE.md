# Periodic Table CRUD - Architecture & Flow Diagram

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER INTERFACE                            │
│                   (periodic_table.blade.php)                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Periodic Table Grid (118 Elements)                      │   │
│  │  - 18 columns × 7 rows (+ lanthanides + actinides)      │   │
│  │  - 40px × 40px elements                                  │   │
│  │  - Color-coded by element type                           │   │
│  │  - Cyan border for elements with articles                │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  "+ Add Periodic" Button (Admin Only)                    │   │
│  │  - Triggers Modal 1: Element Selection                   │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Modal 1: Select Element                                 │   │
│  │  ├── Search Box (filter by name/symbol)                  │   │
│  │  ├── Grid of 118 Elements                                │   │
│  │  └── Click Element → Open Modal 2                        │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Modal 2: Input Form                                     │   │
│  │  ├── Description (textarea)                              │   │
│  │  ├── Table Builder (dynamic rows)                        │   │
│  │  ├── Image Upload (file input)                           │   │
│  │  ├── 3D Model URL (text input)                           │   │
│  │  ├── Real-time Preview                                   │   │
│  │  └── Buttons: Save / Cancel / Delete                     │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    JavaScript Event Handlers
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                        API LAYER                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  POST /api/periodic-articles                                    │
│  ├── Validate input                                             │
│  ├── Upload image to storage                                    │
│  ├── Parse JSON content                                         │
│  └── Save to database                                           │
│                                                                   │
│  GET /api/periodic-articles                                     │
│  └── Return all articles                                        │
│                                                                   │
│  GET /api/periodic-articles/{elementNumber}                     │
│  └── Return specific article                                    │
│                                                                   │
│  DELETE /api/periodic-articles/{elementNumber}                  │
│  ├── Delete image from storage                                  │
│  └── Delete from database                                       │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    CONTROLLER LAYER                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  PeriodicArticleController                                       │
│  ├── index()      → Get all articles                            │
│  ├── show()       → Get specific article                        │
│  ├── store()      → Create/update article                       │
│  └── destroy()    → Delete article                              │
│                                                                   │
│  PeriodicTableController                                         │
│  └── index()      → Render periodic table view                  │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    MODEL LAYER                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  PeriodicArticle Model                                           │
│  ├── Fillable: element_number, element_symbol, description,     │
│  │             content, image_url, model_3d_url                 │
│  ├── Casts: content → array                                     │
│  └── Timestamps: created_at, updated_at                         │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    DATABASE LAYER                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  periodic_articles Table                                         │
│  ├── id (PK)                                                    │
│  ├── element_number (INT, UNIQUE)                               │
│  ├── element_symbol (VARCHAR)                                   │
│  ├── description (TEXT)                                         │
│  ├── content (LONGTEXT - JSON)                                  │
│  ├── image_url (VARCHAR)                                        │
│  ├── model_3d_url (VARCHAR)                                     │
│  ├── created_at (TIMESTAMP)                                     │
│  └── updated_at (TIMESTAMP)                                     │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    STORAGE LAYER                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  storage/app/public/periodic-images/                            │
│  ├── {timestamp}_{filename}.jpg                                 │
│  ├── {timestamp}_{filename}.png                                 │
│  ├── {timestamp}_{filename}.gif                                 │
│  └── {timestamp}_{filename}.webp                                │
│                                                                   │
│  Accessible via: /storage/periodic-images/{filename}            │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 Data Flow Diagram

### Create/Update Article Flow

```
User Input (Form)
    ↓
JavaScript Validation
    ↓
FormData Creation
    ├── element_number
    ├── element_symbol
    ├── description
    ├── image (file)
    ├── model_3d_url
    └── content (JSON string)
    ↓
POST /api/periodic-articles
    ↓
PeriodicArticleController@store()
    ├── Validate Input
    │   ├── element_number: required, 1-118
    │   ├── element_symbol: required
    │   ├── image: optional, image, max 5MB
    │   └── model_3d_url: optional, URL
    ├── Handle File Upload
    │   ├── Store to storage/app/public/periodic-images/
    │   ├── Generate filename: {timestamp}_{original}
    │   └── Return URL: /storage/periodic-images/{filename}
    ├── Parse JSON Content
    │   └── Convert string to array
    └── Save to Database
        ├── updateOrCreate() by element_number
        └── Return article JSON
    ↓
JavaScript Response Handler
    ├── Update articles object
    ├── Update element highlight
    ├── Close modal
    └── Show success alert
    ↓
UI Update
    ├── Element gets cyan border
    └── Preview clears
```

### Read Article Flow

```
Page Load
    ↓
JavaScript DOMContentLoaded
    ├── renderTable() - Render 118 elements
    ├── loadArticles() - Fetch all articles
    └── setupEventListeners() - Setup handlers
    ↓
GET /api/periodic-articles
    ↓
PeriodicArticleController@index()
    ├── Query all articles
    └── Return JSON array
    ↓
JavaScript Response Handler
    ├── Loop through articles
    ├── Store in articles object
    └── updateElementHighlight() for each
    ↓
UI Update
    ├── Elements with articles get cyan border
    └── Ready for user interaction
```

### Edit Article Flow

```
User Clicks Element with Article
    ↓
openEditModal(element)
    ├── Get article from articles object
    ├── Populate form fields
    ├── Load table content
    ├── Show image preview
    └── Show delete button
    ↓
User Edits Form
    ├── Update description
    ├── Modify table rows
    ├── Upload new image
    └── Update 3D model URL
    ↓
User Clicks "Save Article"
    ↓
saveArticle()
    ├── Create FormData
    ├── POST /api/periodic-articles
    └── (Same as Create flow)
```

### Delete Article Flow

```
User Clicks "Delete" Button
    ↓
Confirmation Dialog
    ├── User confirms
    └── User cancels → Stop
    ↓
deleteArticle()
    ├── DELETE /api/periodic-articles/{elementNumber}
    └── Include CSRF token
    ↓
PeriodicArticleController@destroy()
    ├── Find article
    ├── Delete image from storage
    ├── Delete from database
    └── Return success JSON
    ↓
JavaScript Response Handler
    ├── Remove from articles object
    ├── updateElementHighlight()
    ├── Close modal
    └── Show success alert
    ↓
UI Update
    ├── Element border removed
    └── Element clickable again
```

---

## 🔄 Component Interaction

```
┌─────────────────────────────────────────────────────────────────┐
│                    PERIODIC TABLE VIEW                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────┐         ┌──────────────────┐              │
│  │  Periodic Table  │         │  "+ Add Periodic"│              │
│  │  Grid (118 elem) │         │  Button (Admin)  │              │
│  └────────┬─────────┘         └────────┬─────────┘              │
│           │                            │                         │
│           │ Click Element              │ Click Button            │
│           │                            │                         │
│           ↓                            ↓                         │
│  ┌──────────────────────────────────────────────┐               │
│  │  Modal 1: Select Element                     │               │
│  │  ├── Search Box                              │               │
│  │  ├── Grid of 118 Elements                    │               │
│  │  └── Click Element                           │               │
│  └────────┬─────────────────────────────────────┘               │
│           │                                                      │
│           │ Element Selected                                     │
│           ↓                                                      │
│  ┌──────────────────────────────────────────────┐               │
│  │  Modal 2: Input Form                         │               │
│  │  ├── Description                             │               │
│  │  ├── Table Builder                           │               │
│  │  ├── Image Upload                            │               │
│  │  ├── 3D Model URL                            │               │
│  │  ├── Real-time Preview                       │               │
│  │  └── Buttons: Save / Cancel / Delete         │               │
│  └────────┬─────────────────────────────────────┘               │
│           │                                                      │
│           │ Save / Delete                                        │
│           ↓                                                      │
│  ┌──────────────────────────────────────────────┐               │
│  │  API Call                                    │               │
│  │  POST /api/periodic-articles                 │               │
│  │  DELETE /api/periodic-articles/{id}          │               │
│  └────────┬─────────────────────────────────────┘               │
│           │                                                      │
│           │ Response                                             │
│           ↓                                                      │
│  ┌──────────────────────────────────────────────┐               │
│  │  Update UI                                   │               │
│  │  ├── Update articles object                  │               │
│  │  ├── Update element highlight                │               │
│  │  ├── Close modal                             │               │
│  │  └── Show alert                              │               │
│  └──────────────────────────────────────────────┘               │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔐 Security Flow

```
User Request
    ↓
CSRF Token Check
    ├── Token in meta tag
    ├── Token in form submission
    └── Token in API header
    ↓
Authentication Check
    ├── User logged in?
    └── User is admin? (for POST/DELETE)
    ↓
Input Validation
    ├── element_number: 1-118
    ├── element_symbol: string
    ├── image: file type, size
    └── model_3d_url: URL format
    ↓
File Upload Validation
    ├── Type: JPEG, PNG, GIF, WebP
    ├── Size: max 5MB
    └── Store with timestamp prefix
    ↓
Database Operation
    ├── Prepared statements
    ├── Input sanitization
    └── Error handling
    ↓
Response
    ├── JSON response
    └── Error messages
```

---

## 📈 Performance Optimization

```
Frontend
├── Elements loaded from JS array (no DB query)
├── Articles loaded once on page load
├── Real-time preview (no API calls)
├── Lazy loading for images
└── Optimized CSS (minimal repaints)

Backend
├── Single query for all articles
├── Indexed element_number column
├── Proper database relationships
└── Efficient file storage

Storage
├── Local file storage (not external)
├── Optimized image formats
└── Proper directory structure
```

---

## 🎯 Key Features

```
User Interface
├── 118 periodic elements
├── Grid layout (18 columns)
├── Dark theme with cyan accent
├── Responsive design
└── Smooth animations

Functionality
├── Element selection modal
├── Form input modal
├── Real-time preview
├── CRUD operations
└── File upload management

Security
├── CSRF protection
├── Admin authorization
├── Input validation
├── File validation
└── Error handling

Performance
├── Optimized queries
├── Lazy loading
├── Efficient storage
└── Minimal API calls
```

---

**Architecture Version:** 1.0
**Last Updated:** May 27, 2026
