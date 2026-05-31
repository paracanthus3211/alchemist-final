# Periodic Table CRUD Implementation - Complete Guide

## Overview
Implementasi lengkap sistem CRUD untuk Periodic Table dengan fitur advanced article input. Admin dapat menambah, mengedit, dan menghapus artikel untuk setiap elemen.

## Alur Penggunaan

### 1. **Halaman Periodic Table**
- Menampilkan 118 elemen dalam grid 18 kolom
- Setiap elemen berukuran 40px × 40px
- Elemen yang sudah memiliki artikel ditandai dengan border cyan
- Admin melihat tombol "+ Add Periodic" di header

### 2. **Klik Tombol "+ Add Periodic"**
- Modal pertama muncul: **"Select Element to Add"**
- Menampilkan grid semua 118 elemen
- Ada search box untuk mencari elemen
- User dapat mengetik nama atau simbol elemen untuk filter

### 3. **Pilih Element**
- Klik pada elemen yang ingin diisi
- Modal selection tertutup
- Modal form input terbuka dengan judul element (contoh: "Hydrogen (H)")

### 4. **Form Input**
Form memiliki field:
- **Description** (textarea) - Deskripsi singkat elemen
- **Table Content** - Builder tabel dinamis dengan 2 kolom
  - Baris pertama adalah header
  - Tombol "+ Add Row" untuk menambah baris
  - Tombol "Remove" untuk menghapus baris
- **Image Upload** - Upload gambar dari galeri (file input)
  - Preview gambar langsung
  - Maksimal 5MB, format: JPEG, PNG, GIF, WebP
- **3D Model URL** - Link embed untuk model 3D (contoh: Sketchfab)
- **Preview** - Real-time preview semua konten

### 5. **Save Article**
- Klik "Save Article"
- Data dikirim ke API `/api/periodic-articles`
- Gambar di-upload ke `storage/app/public/periodic-images/`
- Elemen mendapat border cyan jika berhasil
- Alert success muncul

### 6. **Edit Existing Article**
- Klik pada elemen yang sudah memiliki artikel
- Form terbuka dengan data yang sudah ada
- Tombol "Delete" muncul
- Edit data dan klik "Save Article"

### 7. **Delete Article**
- Klik tombol "Delete" (hanya muncul jika artikel sudah ada)
- Konfirmasi delete
- Artikel dihapus, elemen kembali normal

## File Structure

### Backend Files
```
app/
├── Http/Controllers/
│   ├── PeriodicTableController.php      # Render halaman
│   └── PeriodicArticleController.php    # API endpoints
├── Models/
│   └── PeriodicArticle.php              # Model dengan fillable & casts
└── Providers/
    └── AppServiceProvider.php

database/
└── migrations/
    └── 2026_05_27_005907_create_periodic_articles_table.php

routes/
├── web.php                              # Web routes
└── api.php                              # API routes

resources/views/
└── periodic_table.blade.php             # Main view dengan JS & CSS

storage/
└── app/public/periodic-images/          # Upload directory
```

## API Endpoints

### Public Endpoints
```
GET /api/periodic-articles
- Deskripsi: Ambil semua artikel
- Response: Array of articles

GET /api/periodic-articles/{elementNumber}
- Deskripsi: Ambil artikel spesifik
- Response: Single article atau 404
```

### Protected Endpoints (Admin Only)
```
POST /api/periodic-articles
- Deskripsi: Buat atau update artikel
- Body: FormData dengan:
  - element_number (required)
  - element_symbol (required)
  - description (optional)
  - image (optional, file)
  - model_3d_url (optional)
  - content (optional, JSON string)
- Response: Created/updated article

DELETE /api/periodic-articles/{elementNumber}
- Deskripsi: Hapus artikel
- Response: Success message
```

## Database Schema

```sql
CREATE TABLE periodic_articles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    element_number INT UNSIGNED NOT NULL,
    element_symbol VARCHAR(255) NOT NULL,
    description TEXT NULLABLE,
    content LONGTEXT NULLABLE,  -- JSON array
    image_url VARCHAR(255) NULLABLE,
    model_3d_url VARCHAR(255) NULLABLE,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    UNIQUE(element_number, element_symbol)
);
```

## Features

### ✅ Implemented
- [x] 118 elemen periodic table
- [x] Grid layout 18 kolom
- [x] Admin-only "+ Add Periodic" button
- [x] Two-step modal (select element → input form)
- [x] Element search/filter
- [x] Text description input
- [x] Dynamic table builder (2 columns)
- [x] Image upload from gallery
- [x] 3D model URL input
- [x] Real-time preview
- [x] Save/Update/Delete operations
- [x] Element highlighting (cyan border)
- [x] File storage management
- [x] CSRF protection
- [x] Responsive design

### 🎨 Styling
- Dark theme (matches Alchemist design)
- Cyan accent color (#00d4d4)
- Smooth transitions
- Hover effects
- Mobile responsive

### 🔒 Security
- CSRF token validation
- File upload validation
- Admin-only operations
- Proper error handling

## Testing Checklist

- [ ] Navigate to `/periodic-table`
- [ ] Verify "+ Add Periodic" button visible (admin only)
- [ ] Click "+ Add Periodic"
- [ ] Verify element selection modal appears
- [ ] Search for element (e.g., "Hydrogen")
- [ ] Click element
- [ ] Verify form modal opens with element name
- [ ] Fill in description
- [ ] Add table rows
- [ ] Upload image
- [ ] Add 3D model URL
- [ ] Verify preview updates in real-time
- [ ] Click "Save Article"
- [ ] Verify element gets cyan border
- [ ] Click element again
- [ ] Verify form opens with saved data
- [ ] Verify "Delete" button appears
- [ ] Edit data and save
- [ ] Delete article
- [ ] Verify element border removed

## Troubleshooting

### Image not uploading
- Check storage permissions: `chmod -R 755 storage/`
- Verify storage link: `php artisan storage:link`
- Check file size (max 5MB)
- Check file type (JPEG, PNG, GIF, WebP)

### CSRF token error
- Verify meta tag in layout: `<meta name="csrf-token" content="{{ csrf_token() }}">`
- Check API header: `X-CSRF-TOKEN`

### Element not highlighting
- Check browser console for errors
- Verify API response
- Check database for saved article

### Modal not closing
- Check for JavaScript errors
- Verify modal IDs match
- Check z-index conflicts

## Performance Notes

- Elements loaded from JavaScript array (no DB query)
- Articles loaded via API on page load
- Images stored locally (not external URLs)
- Lazy loading for images
- Optimized CSS with minimal repaints

## Future Enhancements

- [ ] Batch import articles
- [ ] Article versioning
- [ ] Comments/ratings
- [ ] Share articles
- [ ] Export to PDF
- [ ] Multi-language support
- [ ] Advanced search filters
- [ ] Article templates

## Support

Untuk pertanyaan atau issues, silakan hubungi tim development.
