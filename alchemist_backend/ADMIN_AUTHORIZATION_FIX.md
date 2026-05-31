# Admin Authorization Fix - Periodic Table CRUD

## 🔒 Masalah yang Diperbaiki

### Masalah 1: Tombol "+" Tidak Terlihat
**Sebelum:** Tombol "+ Add Periodic" tidak muncul di header
**Sesudah:** Tombol muncul hanya untuk admin users

### Masalah 2: User Bisa Akses CRUD
**Sebelum:** User non-admin bisa akses API endpoints
**Sesudah:** Hanya admin yang bisa akses POST dan DELETE endpoints

---

## ✅ Solusi yang Diimplementasikan

### 1. Frontend Authorization Check

#### Di View (periodic_table.blade.php)
```blade
<!-- Tambah data attribute untuk admin check -->
<div class="periodic-container" data-is-admin="{{ auth()->check() && (auth()->user()->is_admin || auth()->user()->role === 'ADMIN') ? 'true' : 'false' }}">

<!-- Tombol hanya muncul untuk admin -->
@if(auth()->check() && (auth()->user()->is_admin || auth()->user()->role === 'ADMIN'))
<button class="btn-add-periodic" onclick="openAddModal()">+ Add Periodic</button>
@endif
```

#### Di JavaScript (openAddModal function)
```javascript
function openAddModal() {
    // Check if user is admin
    const isAdmin = document.querySelector('[data-is-admin]')?.getAttribute('data-is-admin') === 'true';
    
    if (!isAdmin) {
        alert('Only admin users can add periodic articles');
        return;
    }
    
    // ... rest of function
}
```

### 2. Backend Authorization Check

#### Di Controller (PeriodicArticleController.php)
```php
public function __construct()
{
    // Protect store dan destroy methods - hanya admin
    $this->middleware('auth:sanctum')->only(['store', 'destroy']);
}

public function store(Request $request)
{
    // Check if user is admin
    if (!auth()->check() || (!auth()->user()->is_admin && auth()->user()->role !== 'ADMIN')) {
        return response()->json(['error' => 'Unauthorized - Admin only'], 403);
    }
    
    // ... rest of function
}

public function destroy($elementNumber)
{
    // Check if user is admin
    if (!auth()->check() || (!auth()->user()->is_admin && auth()->user()->role !== 'ADMIN')) {
        return response()->json(['error' => 'Unauthorized - Admin only'], 403);
    }
    
    // ... rest of function
}
```

### 3. Error Handling

#### Di saveArticle function
```javascript
.then(d => {
    if (d.error) {
        alert('Error: ' + d.error);  // Tampilkan error message
    } else {
        // ... success handling
    }
})
```

#### Di deleteArticle function
```javascript
.then(d => {
    if (d.error) {
        alert('Error: ' + d.error);  // Tampilkan error message
    } else {
        // ... success handling
    }
})
```

---

## 🔐 Authorization Levels

### Admin Users
- ✅ Lihat tombol "+ Add Periodic"
- ✅ Buka modal selection
- ✅ Isi form input
- ✅ Upload image
- ✅ Save article (POST /api/periodic-articles)
- ✅ Edit article
- ✅ Delete article (DELETE /api/periodic-articles/{id})

### Non-Admin Users
- ✅ Lihat periodic table
- ✅ Klik element untuk lihat article
- ✅ Lihat preview article
- ❌ Tidak lihat tombol "+ Add Periodic"
- ❌ Tidak bisa buka modal selection
- ❌ Tidak bisa save article
- ❌ Tidak bisa delete article

---

## 🧪 Testing

### Test 1: Admin User
```
1. Login sebagai admin
2. Buka /periodic-table
3. Verifikasi tombol "+ Add Periodic" muncul
4. Klik tombol
5. Verifikasi modal selection muncul
6. Pilih element
7. Isi form
8. Klik "Save Article"
9. Verifikasi article tersimpan
10. Klik element
11. Verifikasi tombol "Delete" muncul
12. Klik "Delete"
13. Verifikasi article terhapus
```

### Test 2: Non-Admin User
```
1. Login sebagai user biasa
2. Buka /periodic-table
3. Verifikasi tombol "+ Add Periodic" TIDAK muncul
4. Klik element dengan article
5. Verifikasi form terbuka (read-only)
6. Verifikasi tombol "Delete" TIDAK muncul
7. Coba akses API POST /api/periodic-articles
8. Verifikasi error: "Unauthorized - Admin only"
9. Coba akses API DELETE /api/periodic-articles/{id}
10. Verifikasi error: "Unauthorized - Admin only"
```

### Test 3: Non-Authenticated User
```
1. Logout
2. Buka /periodic-table
3. Verifikasi tombol "+ Add Periodic" TIDAK muncul
4. Klik element
5. Verifikasi form terbuka (read-only)
6. Verifikasi tombol "Delete" TIDAK muncul
```

---

## 📋 Checklist

- [x] Tombol "+ Add Periodic" hanya muncul untuk admin
- [x] Frontend check di openAddModal()
- [x] Backend check di store() method
- [x] Backend check di destroy() method
- [x] Error handling di saveArticle()
- [x] Error handling di deleteArticle()
- [x] Middleware auth:sanctum di constructor
- [x] Support untuk is_admin dan role === 'ADMIN'
- [x] Data attribute untuk admin check
- [x] Alert message untuk unauthorized access
- [x] Syntax errors checked
- [x] Views cached

---

## 🔍 Authorization Check Points

### 1. View Level
```blade
@if(auth()->check() && (auth()->user()->is_admin || auth()->user()->role === 'ADMIN'))
    <!-- Tombol hanya muncul untuk admin -->
@endif
```

### 2. JavaScript Level
```javascript
const isAdmin = document.querySelector('[data-is-admin]')?.getAttribute('data-is-admin') === 'true';
if (!isAdmin) {
    alert('Only admin users can add periodic articles');
    return;
}
```

### 3. API Level
```php
if (!auth()->check() || (!auth()->user()->is_admin && auth()->user()->role !== 'ADMIN')) {
    return response()->json(['error' => 'Unauthorized - Admin only'], 403);
}
```

---

## 🛡️ Security Layers

1. **Frontend Check** - Mencegah user non-admin membuka modal
2. **JavaScript Check** - Validasi di browser sebelum API call
3. **Backend Check** - Validasi di server (paling penting)
4. **Middleware** - Auth:sanctum untuk memastikan user authenticated
5. **Error Handling** - Tampilkan error message yang jelas

---

## 📝 User Roles Support

### Supported Admin Checks
```php
// Check 1: is_admin column
auth()->user()->is_admin

// Check 2: role column
auth()->user()->role === 'ADMIN'

// Combined check
auth()->user()->is_admin || auth()->user()->role === 'ADMIN'
```

---

## 🚀 Deployment

### Steps
1. Update controller dengan authorization checks
2. Update view dengan admin check
3. Update JavaScript dengan frontend validation
4. Cache views: `php artisan view:cache`
5. Test dengan admin dan non-admin users

### Verification
```bash
# Check syntax
php -l app/Http/Controllers/PeriodicArticleController.php

# Cache views
php artisan view:cache

# Test API
curl -X POST http://localhost/api/periodic-articles \
  -H "X-CSRF-TOKEN: token" \
  -F "element_number=1" \
  # Should return 403 if not admin
```

---

## 📊 Authorization Matrix

| Action | Admin | User | Guest |
|--------|-------|------|-------|
| View Table | ✅ | ✅ | ✅ |
| View Article | ✅ | ✅ | ✅ |
| See "+ Add" Button | ✅ | ❌ | ❌ |
| Open Modal | ✅ | ❌ | ❌ |
| Save Article | ✅ | ❌ | ❌ |
| Delete Article | ✅ | ❌ | ❌ |

---

## 🔗 Related Files

- `app/Http/Controllers/PeriodicArticleController.php` - Backend authorization
- `resources/views/periodic_table.blade.php` - Frontend authorization
- `routes/api.php` - API routes dengan middleware

---

## ✨ Status

**Status:** ✅ COMPLETE
**Testing:** ✅ READY
**Deployment:** ✅ READY

---

**Last Updated:** May 27, 2026
