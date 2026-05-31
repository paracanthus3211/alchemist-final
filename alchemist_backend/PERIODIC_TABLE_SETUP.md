# Periodic Table Setup Guide

## Installation Steps

### 1. Database Migration
Jalankan migration untuk membuat tabel `periodic_articles`:

```bash
php artisan migrate
```

Atau jika ingin rollback dan migrate ulang:
```bash
php artisan migrate:refresh
```

### 2. Verify Files Created

Pastikan file-file berikut sudah ada:

```
resources/views/
├── periodic_table.blade.php

app/Http/Controllers/
├── PeriodicTableController.php
├── PeriodicArticleController.php

app/Models/
├── PeriodicArticle.php (sudah ada, updated)

database/migrations/
├── 2026_05_27_005907_create_periodic_articles_table.php (updated)

routes/
├── api.php (updated)
├── web.php (sudah ada)

tests/Feature/
├── PeriodicTableTest.php
```

### 3. Routes

#### Web Routes
```
GET /periodic-table              # View periodic table
```

#### API Routes (Public)
```
GET /api/periodic-articles              # Get all articles
GET /api/periodic-articles/{elementNumber}  # Get specific article
```

#### API Routes (Authenticated)
```
POST   /api/periodic-articles            # Create/Update article
DELETE /api/periodic-articles/{elementNumber}  # Delete article
```

### 4. Testing

Run tests untuk memastikan semuanya berfungsi:

```bash
php artisan test tests/Feature/PeriodicTableTest.php
```

### 5. Access the Application

1. Login ke aplikasi
2. Buka `/periodic-table`
3. Klik elemen untuk membuka modal edit
4. Isi form dan klik "Save"

## Features

### Display
- ✓ 118 elemen periodik
- ✓ Grid layout 18 kolom
- ✓ Ukuran elemen 40px x 40px
- ✓ Scroll horizontal smooth
- ✓ Responsive design
- ✓ 10 kategori warna

### CRUD Operations
- ✓ Create/Update artikel
- ✓ Read artikel
- ✓ Delete artikel
- ✓ Preview real-time

### Form Fields
- ✓ Description
- ✓ Image URL
- ✓ 3D Model URL
- ✓ Content

## Troubleshooting

### Modal tidak muncul
- Pastikan JavaScript tidak ada error di console
- Cek apakah CSRF token ada di meta tag

### API tidak merespons
- Pastikan routes sudah di-register di `routes/api.php`
- Cek apakah controller sudah di-import

### Database error
- Jalankan `php artisan migrate`
- Pastikan migration file sudah ada

### Styling tidak bekerja
- Clear browser cache
- Jalankan `php artisan view:clear`

## Performance Tips

1. **Lazy Load Articles**: Articles dimuat saat halaman load
2. **Smooth Scrolling**: CSS-based scrolling untuk performa optimal
3. **Minimal JavaScript**: Hanya untuk interaksi modal
4. **Efficient Grid**: CSS Grid untuk layout yang optimal

## Security

- CSRF protection untuk semua POST/DELETE requests
- Input validation di backend
- Admin-only endpoints (dapat ditambahkan di controller)

## Future Enhancements

- [ ] Batch import articles dari CSV
- [ ] Search/filter elements
- [ ] Export to PDF
- [ ] Multi-language support
- [ ] Advanced content builder dengan drag-drop
- [ ] Element comparison tool
- [ ] Periodic table quiz
- [ ] Element discovery game

## Support

Untuk pertanyaan atau masalah, silakan buat issue di repository.
