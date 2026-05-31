# Periodic Table - Quick Reference

## Quick Start

```bash
# 1. Run migration
php artisan migrate

# 2. Clear cache
php artisan view:clear

# 3. Access application
# Login and go to /periodic-table
```

## File Locations

```
View:       resources/views/periodic_table.blade.php
Controller: app/Http/Controllers/PeriodicArticleController.php
Model:      app/Models/PeriodicArticle.php
Migration:  database/migrations/2026_05_27_005907_create_periodic_articles_table.php
Routes:     routes/api.php, routes/web.php
Tests:      tests/Feature/PeriodicTableTest.php
```

## API Endpoints

```
GET    /api/periodic-articles              # Get all
GET    /api/periodic-articles/{id}         # Get one
POST   /api/periodic-articles              # Create/Update
DELETE /api/periodic-articles/{id}         # Delete
```

## Database Schema

```sql
CREATE TABLE periodic_articles (
    id BIGINT PRIMARY KEY,
    element_number BIGINT UNSIGNED,
    element_symbol VARCHAR(255),
    description TEXT,
    content LONGTEXT,
    image_url VARCHAR(255),
    model_3d_url VARCHAR(255),
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    UNIQUE(element_number, element_symbol)
);
```

## Model Usage

```php
// Get all articles
$articles = PeriodicArticle::all();

// Get specific element
$article = PeriodicArticle::where('element_number', 1)->first();

// Create/Update
PeriodicArticle::updateOrCreate(
    ['element_number' => 1],
    ['description' => 'Hydrogen', ...]
);

// Delete
PeriodicArticle::where('element_number', 1)->delete();
```

## Form Fields

| Field | Type | Required | Example |
|-------|------|----------|---------|
| element_number | Integer | Yes | 1 |
| element_symbol | String | Yes | H |
| description | Text | No | Hydrogen is... |
| image_url | URL | No | https://... |
| model_3d_url | URL | No | https://... |
| content | Text | No | Content here |

## Element Categories

```
alkali-metal      → #1d3557
alkaline-earth    → #03045e
transition-metal  → #005f73
lanthanide        → #14746f
actinide          → #06d6a0
metalloid         → #52b788
nonmetal          → #7f5539
halogen           → #fb8500
noble-gas         → #ff007f
unknown           → #4a4e69
```

## JavaScript Functions

```javascript
// Open modal
openModal(element)

// Close modal
closeModal()

// Save article
saveArticle()

// Delete article
deleteArticle()

// Update preview
updatePreview()

// Load articles
loadArticles()

// Render table
renderTable()
```

## Common Tasks

### Add New Article
```javascript
const data = {
    element_number: 1,
    element_symbol: 'H',
    description: 'Hydrogen',
    image_url: 'https://...',
    model_3d_url: 'https://...',
    content: 'Content'
};

fetch('/api/periodic-articles', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': token
    },
    body: JSON.stringify(data)
});
```

### Get All Articles
```javascript
fetch('/api/periodic-articles')
    .then(r => r.json())
    .then(data => console.log(data));
```

### Delete Article
```javascript
fetch('/api/periodic-articles/1', {
    method: 'DELETE',
    headers: {'X-CSRF-TOKEN': token}
});
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Modal not showing | Check console for JS errors |
| API 404 | Verify routes in api.php |
| Database error | Run `php artisan migrate` |
| Styling broken | Clear cache: `php artisan view:clear` |
| CSRF error | Check meta csrf-token tag |

## Performance Tips

1. Use lazy loading for articles
2. Cache API responses
3. Minimize JavaScript
4. Use CSS Grid for layout
5. Optimize images

## Security Notes

- Always validate input on backend
- Use CSRF tokens for POST/DELETE
- Check authentication before API calls
- Sanitize user input
- Use prepared statements

## Testing

```bash
# Run all tests
php artisan test

# Run specific test
php artisan test tests/Feature/PeriodicTableTest.php

# Run with coverage
php artisan test --coverage
```

## Deployment

```bash
# 1. Run migrations
php artisan migrate --force

# 2. Clear cache
php artisan cache:clear
php artisan view:clear

# 3. Optimize
php artisan optimize

# 4. Verify
php artisan route:list | grep periodic
```

## Element Count

- Total: 118 elements
- Rows: 9 (including lanthanides & actinides)
- Columns: 18
- Categories: 10

## Browser Support

- Chrome/Edge: ✓
- Firefox: ✓
- Safari: ✓
- Mobile: ✓

## Responsive Breakpoints

- Desktop: > 1024px
- Tablet: 768px - 1024px
- Mobile: < 768px

## Links

- [Documentation](PERIODIC_TABLE_DOCS.md)
- [Setup Guide](PERIODIC_TABLE_SETUP.md)
- [Implementation Summary](PERIODIC_TABLE_SUMMARY.md)
- [Checklist](PERIODIC_TABLE_CHECKLIST.md)

---

**Version**: 1.0.0
**Status**: Production Ready
