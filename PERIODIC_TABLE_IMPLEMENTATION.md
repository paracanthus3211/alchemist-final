# Periodic Table Implementation Guide

## File Created
- **Location**: `resources/views/periodic_table.blade.php`
- **Size**: 557 lines
- **Status**: ✅ Complete and ready to use

## Features Implemented

### 1. Periodic Table Grid
- ✅ 118 elements displayed in a 18-column grid
- ✅ 40px × 40px element boxes
- ✅ Color-coded by element type (alkali metals, halogens, noble gases, etc.)
- ✅ Smooth horizontal scrolling
- ✅ Responsive design (adapts to mobile)
- ✅ Element numbers and symbols displayed
- ✅ Hover effects with scale and glow

### 2. Admin Controls
- ✅ "+ Add Periodic" button (visible only to admin users)
- ✅ Button positioned in header next to title
- ✅ Cyan color (#00d4d4) matching design system

### 3. Modal Form
The modal opens when:
- Admin clicks "+ Add Periodic" button (new article)
- Any user clicks an element (view/edit if admin)

#### Form Inputs:
1. **Description** (textarea)
   - Multi-line text input
   - Real-time preview
   - Placeholder text

2. **Table Builder**
   - Dynamic row creation
   - 2-column table structure
   - Add/Remove row buttons
   - Real-time preview with formatted table

3. **Image Upload**
   - File input (accepts image files only)
   - Shows selected filename
   - Displays image preview
   - Stores as file upload (not URL)

4. **3D Model URL**
   - Text input for embed links
   - Real-time preview with clickable link
   - Opens in new tab

5. **Real-time Preview**
   - Shows formatted description
   - Displays uploaded image
   - Shows table with headers
   - Shows 3D model link
   - Updates as user types

### 4. Buttons
- **Save Article**: Saves all data to database
- **Cancel**: Closes modal without saving
- **Delete**: Removes article (only shown if article exists)

### 5. Visual Indicators
- ✅ Elements with articles have cyan border highlight
- ✅ Modal header shows element name and symbol
- ✅ Close button (×) in modal header
- ✅ CSRF token protection

## Data Structure

### Database Table: `periodic_articles`
```
- id (primary key)
- element_number (1-118)
- element_symbol (H, He, Li, etc.)
- description (text content)
- content (JSON array for table data)
- image_url (path to uploaded file)
- model_3d_url (embed link)
- created_at
- updated_at
```

### Table Content Format (JSON)
```json
[
  ["Property", "Value"],
  ["Atomic Mass", "1.008"],
  ["Electron Config", "1s¹"]
]
```

## API Endpoints Required

### GET /api/periodic-articles
Returns all periodic articles

### POST /api/periodic-articles
Creates or updates an article
- Accepts FormData with file upload
- Fields: element_number, element_symbol, description, content, image, model_3d_url

### DELETE /api/periodic-articles/{elementNumber}
Deletes an article by element number

## Styling Features

### Color Scheme
- Background: Dark (#1a1a1a)
- Text: White (#fff)
- Accent: Cyan (#00d4d4)
- Danger: Red (#ff4444)
- Success: Green (#06d6a0)

### Responsive Design
- Desktop: Full width with sidebar (260px margin)
- Mobile: Full width, stacked layout
- Modal: Adapts to screen size

### Element Categories
- Alkali Metals: #1d3557
- Alkaline Earth: #03045e
- Transition Metals: #005f73
- Lanthanides: #14746f
- Actinides: #06d6a0
- Metalloids: #52b788
- Nonmetals: #7f5539
- Halogens: #fb8500
- Noble Gases: #ff007f

## JavaScript Functions

### Core Functions
- `renderTable()` - Renders 118 elements
- `openAddModal()` - Opens form for new article
- `openEditModal(el)` - Opens form for existing element
- `closeModal()` - Closes modal
- `saveArticle()` - Saves article via API
- `deleteArticle()` - Deletes article via API
- `loadArticles()` - Loads all articles on page load
- `updateElementHighlight(elementNumber)` - Adds border to elements with articles

### Table Builder Functions
- `addTableRow()` - Adds new row to table
- `removeTableRow(btn)` - Removes row from table
- `getTableContent()` - Extracts table data as JSON

### Preview Functions
- `updatePreview()` - Updates real-time preview
- `handleImageUpload(event)` - Handles file upload

### Event Listeners
- Input listeners for description and model URL
- Table input listeners for dynamic updates
- Modal click-outside to close

## Security Features

✅ CSRF Token Protection
- Automatically included in form
- Sent with all API requests

✅ Admin-Only Controls
- "+ Add Periodic" button only visible to admins
- Delete button only shown for existing articles

✅ File Upload Validation
- Accepts only image files
- Stored server-side (not URL-based)

## Usage Instructions

### For Admin Users
1. Click "+ Add Periodic" button
2. Fill in description, table data, upload image, add 3D model link
3. Watch real-time preview update
4. Click "Save Article"

### For All Users
1. Click any element to view its article (if exists)
2. If admin, can edit or delete the article

### Adding Table Data
1. First row is header row
2. Click "+ Add Row" to add data rows
3. Fill in column values
4. Click "Remove" to delete a row
5. Preview shows formatted table

## File Storage

Images are uploaded as files and stored at:
- `storage/app/public/periodic-images/`

The API should handle:
- File validation
- Unique filename generation
- Path storage in database

## Notes

- All 118 elements are included with correct atomic numbers
- Element categories are color-coded for easy identification
- Form is clean and simple, no unnecessary fields
- No duplicate elements possible (one article per element)
- Responsive design works on all screen sizes
- Real-time preview helps users see exactly what will be saved
- Modal can be closed by clicking X, Cancel, or clicking outside

## Next Steps

1. Create API endpoints in controller
2. Create migration for periodic_articles table
3. Update PeriodicArticle model with proper relationships
4. Set up file storage directory
5. Test file upload functionality
6. Verify CSRF token handling
