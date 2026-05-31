# Periodic Table - Data Examples

## Contoh Data yang Bisa Disimpan

### Example 1: Hydrogen (H)

**Form Input:**
```
Description:
"Hydrogen adalah elemen paling ringan dan paling melimpah di alam semesta. 
Digunakan dalam berbagai aplikasi industri dan penelitian."

Table Content:
| Property | Value |
|----------|-------|
| Atomic Number | 1 |
| Atomic Mass | 1.008 |
| Electron Config | 1s¹ |
| State | Gas |

Image: hydrogen.jpg (uploaded)

3D Model URL: https://sketchfab.com/models/hydrogen-3d
```

**Database Storage:**
```json
{
  "id": 1,
  "element_number": 1,
  "element_symbol": "H",
  "description": "Hydrogen adalah elemen paling ringan...",
  "content": [
    ["Property", "Value"],
    ["Atomic Number", "1"],
    ["Atomic Mass", "1.008"],
    ["Electron Config", "1s¹"],
    ["State", "Gas"]
  ],
  "image_url": "/storage/periodic-images/1234567890_hydrogen.jpg",
  "model_3d_url": "https://sketchfab.com/models/hydrogen-3d",
  "created_at": "2026-05-27 10:30:00",
  "updated_at": "2026-05-27 10:30:00"
}
```

---

### Example 2: Carbon (C)

**Form Input:**
```
Description:
"Karbon adalah elemen yang sangat penting dalam kimia organik. 
Membentuk dasar dari semua makhluk hidup dan memiliki banyak alotrope."

Table Content:
| Karakteristik | Deskripsi |
|---------------|-----------|
| Warna | Hitam/Transparan |
| Kekerasan | Sangat Keras (Diamond) |
| Konduktivitas | Baik (Graphite) |
| Titik Leleh | 3823 K |

Image: carbon.jpg (uploaded)

3D Model URL: https://sketchfab.com/models/carbon-structure
```

**Database Storage:**
```json
{
  "id": 6,
  "element_number": 6,
  "element_symbol": "C",
  "description": "Karbon adalah elemen yang sangat penting...",
  "content": [
    ["Karakteristik", "Deskripsi"],
    ["Warna", "Hitam/Transparan"],
    ["Kekerasan", "Sangat Keras (Diamond)"],
    ["Konduktivitas", "Baik (Graphite)"],
    ["Titik Leleh", "3823 K"]
  ],
  "image_url": "/storage/periodic-images/1234567891_carbon.jpg",
  "model_3d_url": "https://sketchfab.com/models/carbon-structure",
  "created_at": "2026-05-27 11:00:00",
  "updated_at": "2026-05-27 11:00:00"
}
```

---

### Example 3: Gold (Au)

**Form Input:**
```
Description:
"Emas adalah logam mulia yang sangat berharga. 
Digunakan dalam perhiasan, elektronik, dan aplikasi medis."

Table Content:
| Sifat | Nilai |
|-------|-------|
| Nomor Atom | 79 |
| Massa Atom | 196.97 |
| Densitas | 19.3 g/cm³ |
| Titik Leleh | 1337 K |
| Warna | Kuning Emas |

Image: gold.jpg (uploaded)

3D Model URL: https://sketchfab.com/models/gold-crystal
```

**Database Storage:**
```json
{
  "id": 79,
  "element_number": 79,
  "element_symbol": "Au",
  "description": "Emas adalah logam mulia yang sangat berharga...",
  "content": [
    ["Sifat", "Nilai"],
    ["Nomor Atom", "79"],
    ["Massa Atom", "196.97"],
    ["Densitas", "19.3 g/cm³"],
    ["Titik Leleh", "1337 K"],
    ["Warna", "Kuning Emas"]
  ],
  "image_url": "/storage/periodic-images/1234567892_gold.jpg",
  "model_3d_url": "https://sketchfab.com/models/gold-crystal",
  "created_at": "2026-05-27 12:00:00",
  "updated_at": "2026-05-27 12:00:00"
}
```

---

## API Request Examples

### Create Article (POST)

```bash
curl -X POST http://localhost/api/periodic-articles \
  -H "X-CSRF-TOKEN: your-csrf-token" \
  -H "Accept: application/json" \
  -F "element_number=1" \
  -F "element_symbol=H" \
  -F "description=Hydrogen adalah elemen paling ringan..." \
  -F "image=@/path/to/hydrogen.jpg" \
  -F "model_3d_url=https://sketchfab.com/models/hydrogen-3d" \
  -F "content=[[\"Property\",\"Value\"],[\"Atomic Number\",\"1\"]]"
```

### Get All Articles (GET)

```bash
curl http://localhost/api/periodic-articles \
  -H "Accept: application/json"
```

**Response:**
```json
[
  {
    "id": 1,
    "element_number": 1,
    "element_symbol": "H",
    "description": "Hydrogen adalah elemen paling ringan...",
    "content": [...],
    "image_url": "/storage/periodic-images/...",
    "model_3d_url": "https://...",
    "created_at": "2026-05-27T10:30:00.000000Z",
    "updated_at": "2026-05-27T10:30:00.000000Z"
  },
  ...
]
```

### Get Specific Article (GET)

```bash
curl http://localhost/api/periodic-articles/1 \
  -H "Accept: application/json"
```

### Delete Article (DELETE)

```bash
curl -X DELETE http://localhost/api/periodic-articles/1 \
  -H "X-CSRF-TOKEN: your-csrf-token" \
  -H "Accept: application/json"
```

---

## Form Validation Rules

```php
[
    'element_number' => 'required|integer|min:1|max:118',
    'element_symbol' => 'required|string',
    'description' => 'nullable|string',
    'image' => 'nullable|image|mimes:jpeg,png,gif,webp|max:5120',
    'model_3d_url' => 'nullable|url',
    'content' => 'nullable|string',  // JSON string
]
```

---

## File Upload Details

### Supported Formats
- JPEG (.jpg, .jpeg)
- PNG (.png)
- GIF (.gif)
- WebP (.webp)

### Size Limits
- Maximum: 5MB
- Recommended: 1-2MB

### Storage Location
```
storage/app/public/periodic-images/
```

### Access URL
```
/storage/periodic-images/{filename}
```

### Filename Format
```
{timestamp}_{original_filename}
Example: 1234567890_hydrogen.jpg
```

---

## Table Content Format

### Structure
```json
[
  ["Header1", "Header2"],
  ["Value1", "Value2"],
  ["Value3", "Value4"]
]
```

### Rules
- Baris pertama adalah header
- Minimal 1 baris data
- Maksimal unlimited baris
- 2 kolom per baris

### Example
```json
[
  ["Property", "Value"],
  ["Atomic Number", "1"],
  ["Atomic Mass", "1.008"],
  ["Electron Config", "1s¹"],
  ["State", "Gas"]
]
```

---

## Preview Display

### What Gets Displayed
1. **Description** - Teks deskripsi
2. **Image** - Gambar yang di-upload
3. **Table** - Tabel dengan styling
4. **3D Model** - Link yang bisa diklik

### Preview Update
- Real-time saat user mengetik
- Update saat image di-upload
- Update saat table row ditambah/dihapus

---

## Best Practices

### Description
- Gunakan 2-3 paragraf
- Jelaskan sifat dan kegunaan elemen
- Gunakan bahasa yang mudah dipahami

### Table
- Gunakan header yang jelas
- Satu informasi per baris
- Gunakan unit yang konsisten

### Image
- Gunakan gambar berkualitas tinggi
- Ukuran optimal: 800x600px
- Format: PNG atau JPEG

### 3D Model URL
- Gunakan platform resmi (Sketchfab, etc)
- Pastikan link valid dan accessible
- Gunakan embed link jika tersedia

---

## Common Issues & Solutions

### Image tidak muncul di preview
→ Pastikan file sudah di-upload
→ Check browser console untuk errors

### Table tidak terformat dengan baik
→ Pastikan JSON format benar
→ Gunakan 2 kolom per baris

### 3D Model link tidak berfungsi
→ Verifikasi URL valid
→ Pastikan link accessible dari browser

### Data tidak tersimpan
→ Check CSRF token
→ Verify API response
→ Check server logs

---

**Last Updated:** May 27, 2026
