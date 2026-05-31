# Periodic Table CRUD Documentation

## Overview
File `periodic_table.blade.php` menampilkan tabel periodik interaktif dengan 118 elemen. Admin dapat menambah, mengedit, dan menghapus artikel untuk setiap elemen.

## Features

### 1. Display
- **118 Elemen** dengan layout grid 18 kolom
- **Ukuran Elemen**: 40px x 40px (tidak nabrak sidebar)
- **Scroll Horizontal**: Smooth scrolling dengan custom scrollbar
- **Responsive**: Menyesuaikan dengan ukuran layar
- **Kategori Warna**: 10 kategori elemen dengan warna berbeda

### 2. CRUD Operations
- **Create/Update**: Admin dapat menambah atau mengubah artikel elemen
- **Read**: Semua user dapat melihat artikel
- **Delete**: Admin dapat menghapus artikel

### 3. Form Input
- **Description**: Deskripsi singkat elemen
- **Image URL**: URL gambar elemen
- **3D Model URL**: URL model 3D (Sketchfab, dll)
- **Content**: Konten artikel lengkap

### 4. Preview
- Preview real-time saat mengetik
- Menampilkan deskripsi, gambar, link 3D, dan konten

## File Structure

```
resources/views/
├── periodic_table.blade.php          # Main view dengan CRUD UI
app/Http/Controllers/
├── PeriodicArticleController.php      # API Controller
app/Models/
├── PeriodicArticle.php                # Model
database/migrations/
├── 2026_05_27_005907_create_periodic_articles_table.php
routes/
├── api.php                            # API Routes
```

## API Endpoints

### Public Endpoints
```
GET  /api/periodic-articles              # Get all articles
GET  /api/periodic-articles/{elementNumber}  # Get specific article
```

### Admin Endpoints (Authenticated)
```
POST   /api/periodic-articles            # Create/Update article
DELETE /api/periodic-articles/{elementNumber}  # Delete article
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

## Usage

### View Periodic Table
```
GET /periodic-table
```

### Add/Edit Article (Admin)
1. Klik elemen di tabel
2. Isi form dengan data
3. Preview akan update real-time
4. Klik "Save" untuk menyimpan

### Delete Article (Admin)
1. Klik elemen
2. Klik tombol "Delete"
3. Konfirmasi penghapusan

## Element Categories

| Category | Color | Examples |
|----------|-------|----------|
| Alkali Metal | #1d3557 | Li, Na, K |
| Alkaline Earth | #03045e | Be, Mg, Ca |
| Transition Metal | #005f73 | Fe, Cu, Zn |
| Lanthanide | #14746f | La, Ce, Pr |
| Actinide | #06d6a0 | U, Pu, Th |
| Metalloid | #52b788 | B, Si, As |
| Nonmetal | #7f5539 | C, N, O |
| Halogen | #fb8500 | F, Cl, Br |
| Noble Gas | #ff007f | He, Ne, Ar |
| Unknown | #4a4e69 | Uut, Uup, Uus |

## Responsive Design

- **Desktop**: Full layout dengan sidebar
- **Tablet**: Adjusted padding
- **Mobile**: Full width, sidebar hidden

## Security

- CSRF protection untuk semua POST/DELETE requests
- Admin-only endpoints (dapat ditambahkan di controller)
- Input validation di backend

## Performance

- Lazy loading articles
- Smooth scrolling dengan CSS
- Minimal JavaScript untuk rendering
- Efficient grid layout

## Browser Support

- Chrome/Edge: ✓
- Firefox: ✓
- Safari: ✓
- Mobile browsers: ✓

## Future Enhancements

- [ ] Batch import articles
- [ ] Search/filter elements
- [ ] Export to PDF
- [ ] Multi-language support
- [ ] Advanced content builder
- [ ] Element comparison tool
