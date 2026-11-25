# 🍓 Panduan Desain: Kawaii Soft-Pink (Anti-AI Slop)

Dokumen ini berfungsi sebagai **Design System** sekaligus **Aturan Prompt (Ruleset)** untuk memastikan antarmuka (UI) dan aset visual memiliki estetika **pink yang lucu, hangat, dan menggemaskan**, tanpa terjebak dalam pola desain generik buatan AI (*AI slop*).

---

## 1. Manifesto Anti-AI Slop

Desain yang terasa seperti *AI slop* biasanya mudah dikenali karena terlalu simetris, steril, memakai warna neon menyilaukan, dan tidak memiliki "rasa" sentuhan manusia. Terapkan aturan berikut untuk menghindarinya:

### ❌ Dilarang Keras (Anti-Patterns)
- **Layout Template Generik:** Hindari struktur *Hero teks di tengah + 3 kartu fitur sejajar di bawahnya + latar belakang gradasi buram (blur blobs)* yang membosankan.
- **Pink Neon / Magenta Kasar:** Jangan gunakan `#FF00FF` atau `#FF1493` di atas latar putih murni (`#FFFFFF`) karena membuat mata cepat lelah dan terkesan murahan.
- **Hitam Pekat & Abu-abu Dingin:** Jangan gunakan `#000000` untuk teks atau `#808080` untuk bayangan—keduanya membuat warna pink terlihat "kotor".
- **Bayangan Kabur Berlebihan:** Hindari *drop-shadow* abu-abu besar yang mengambang tanpa arah (`box-shadow: 0 20px 50px rgba(0,0,0,0.15)`).
- **Copywriting Kaku:** Hindari frasa klise seperti *"Tingkatkan produktivitas Anda"*, *"Solusi revolusioner"*, atau penggunaan emoji acak di setiap awal kalimat.

### ✅ Prinsip Utama (Kawaii & Tactile)
- **Tactile & Squishy (Empuk & Terasa Nyata):** Elemen UI harus terasa seperti stiker vinil, kue mochi, atau buku jurnal fisik. Gunakan tepian lembut, border yang jelas, dan efek membal saat ditekan.
- **Warmth Over Sterility (Hangat & Manis):** Gunakan nuansa susu stroberi, krim persik, dan cokelat hangat alih-alih putih dingin dan hitam pekat.
- **Asimetri Terkontrol (Bento & Scrapbook):** Susun elemen layaknya tata letak *bento box* atau halaman *scrapbook* majalah Jepang/Korea yang dinamis namun tetap rapi.

---

## 2. Palet Warna: "Strawberry Milk & Cocoa"

Gunakan kombinasi warna hangat agar kontras tetap nyaman dibaca (ramah aksesibilitas) namun tetap manis dipandang.

| Peran Warna | Nama Warna | Kode Hex | Penggunaan |
| :--- | :--- | :--- | :--- |
| **Background Utama** | *Warm Strawberry Milk* | `#FFF8FA` | Latar belakang halaman utama (pengganti putih polos). |
| **Surface / Kartu** | *Soft Mochi Blush* | `#FFEFF4` | Latar kartu, modal, atau kontainer sekunder. |
| **Surface Elevasi** | *Pure Cream* | `#FFFFFF` | Latar kolom input atau kartu utama di atas background blush. |
| **Primary Accent** | *Strawberry Jam* | `#F4729B` | Tombol utama, ikon aktif, dan elemen fokus. |
| **Primary Hover** | *Raspberry Glaze* | `#E0527F` | Warna tombol saat disentuh kursor (*hover*). |
| **Secondary Accent** | *Peach Sorbet* | `#FFD6A5` | Badge, label kategori, dan variasi agar tidak monoton pink. |
| **Tertiary Accent** | *Buttercream Yellow* | `#FFF0C2` | Highlight teks, stiker catatan, atau bintang dekoratif. |
| **Teks Utama (Dark)** | *Dark Cocoa Espresso* | `#4A2C36` | Pengganti warna hitam. Memberikan kontras tajam namun hangat. |
| **Teks Sekunder** | *Dusty Rose* | `#8C6270` | Subjudul, caption, placeholder, dan informasi pendukung. |
| **Border / Garis** | *Cotton Candy Line* | `#F5C6D6` | Garis tepi kartu, pembatas, dan outline tombol. |

### Warna Semantik (Pastel Harmonized)
- **Sukses (Matcha Milk):** Teks `#2D6A4F` | Latar `#E6F7EF` | Border `#A3DEC2`
- **Peringatan (Honey Tart):** Teks `#7C5318` | Latar `#FFF6DB` | Border `#F5D684`
- **Error (Cherry Pop):** Teks `#9E2A3B` | Latar `#FFE8EC` | Border `#F4A5B2`

---

## 3. Tipografi yang Menggemaskan

Tipografi adalah kunci utama membedakan desain berkarakter dengan template standar. **Jangan gunakan Inter, Roboto, atau Arial.**

1. **Heading / Judul (Bulat, Ramah, & Ekspresif):**
   - **Rekomendasi Utama:** `Fredoka`, `Quicksand`, atau `Nunito` (Weight: `600` atau `700`).
   - **Karakteristik:** Ujung huruf yang membulat memberikan kesan ramah, ceria, dan menggemaskan tanpa mengurangi keterbacaan.
   - **Aturan:** Gunakan `letter-spacing: -0.01em` untuk judul besar agar terlihat padat dan manis.

2. **Body Text / Paragraf (Bersih & Lembut):**
   - **Rekomendasi Utama:** `Plus Jakarta Sans` atau `DM Sans` (Weight: `400` dan `500`).
   - **Aturan:** Gunakan `line-height: 1.65` agar teks terasa lapang dan nyaman dibaca.

3. **Aksen Tulisan Tangan / Stiker (Opsional & Hemat):**
   - **Rekomendasi:** `Caveat` atau `Patrick Hand` untuk catatan kecil di pinggir kartu (misal: *"Favorit!"* atau *"Baru rilis ✨"*).

---

## 4. Geometri, Border, & Efek "Sticker"

Untuk menciptakan efek *tactile* (bisa diraba) yang jauh dari kesan kaku:

- **Sudut Membulat (Border Radius):**
  - Kartu besar / Kontainer: `24px`
  - Kartu kecil / Input field: `16px`
  - Tombol & Badge: `9999px` (bentuk pil/kapsul penuh)
- **Gaya Bayangan "Kawaii Pop" (Pengganti Drop Shadow Biasa):**
  Gunakan kombinasi border solid dan bayangan padat (*hard-offset shadow*) berwarna pink lembut agar elemen terlihat seperti stiker timbul:
  ```css
  border: 2px solid #F5C6D6;
  box-shadow: 0 4px 0 #F2B5C8;
  ```
- **Tekstur Latar Belakang (Subtle Pattern):**
  Daripada latar belakang polos, tambahkan pola titik polka (*polka dots*) sangat halus atau kotak-kotak buku tulis (*grid paper*) dengan opasitas rendah (`3% - 5%`) berwarna `#F4729B`.

---

## 5. Micro-Interactions & Animasi

Interaksi pada desain menggemaskan harus terasa **membal (*bouncy*)** seperti agar-agar atau permen karet, bukan kaku dan linear.

- **Kurva Animasi Wajib (Spring/Bouncy Easing):**
  ```css
  transition: all 0.25s cubic-bezier(0.34, 1.56, 0.64, 1);
  ```
- **Interaksi Tombol (Squishy Button):**
  - **Normal:** `transform: translateY(0); box-shadow: 0 4px 0 #C9406B;`
  - **Hover:** `transform: translateY(-2px); box-shadow: 0 6px 0 #C9406B;`
  - **Active (Saat diklik):** `transform: translateY(3px); box-shadow: 0 1px 0 #C9406B;` (tombol terasa benar-benar tertekan ke bawah).
- **Ornamen SVG Kustom (Gunakan secukupnya):**
  Sisipkan ilustrasi vektor garis tipis (*line-art* dengan ujung membulat/`stroke-linecap: round`) seperti kilau bintang 4 sudut (`✦`), awan kecil, pita, atau hati minimalis sebagai pemanis di sudut kartu.

---

## 6. Gaya Bahasa & Microcopy

Sesuaikan nada tulisan (*tone of voice*) agar selaras dengan visualnya: hangat, suportif, santai, dan personal.

| Konteks | ❌ Gaya Robot / AI Slop | ✅ Gaya Kawaii & Manusiawi |
| :--- | :--- | :--- |
| **Empty State** | *Tidak ada data yang ditemukan di sistem.* | *Wah, masih kosong nih! Yuk, tambah catatan pertamamu.* |
| **Tombol Simpan** | *Submit Perubahan* | *Simpan ✨* atau *Simpan Perubahan* |
| **Pesan Sukses** | *Operasi berhasil dieksekusi.* | *Yeay! Datamu sudah tersimpan rapi.* |
| **Pesan Error** | *Input tidak valid. Periksa kembali.* | *Ups, sepertinya ada yang terlewat. Cek lagi yuk!* |

---

## 7. Token CSS Siap Pakai (`variables.css`)

Salin variabel berikut ke dalam proyek untuk langsung menerapkan sistem warna dan gaya ini:

```css
:root {
  /* Palette */
  --bg-canvas: #FFF8FA;
  --bg-surface: #FFEFF4;
  --bg-elevated: #FFFFFF;

  --pink-primary: #F4729B;
  --pink-hover: #E0527F;
  --pink-shadow: #C9406B;
  --pink-border: #F5C6D6;
  --pink-soft-shadow: #F2B5C8;

  --accent-peach: #FFD6A5;
  --accent-butter: #FFF0C2;

  /* Typography Colors */
  --ink-primary: #4A2C36;
  --ink-secondary: #8C6270;
  --ink-on-pink: #FFFFFF;

  /* Geometry & Tactile Shadows */
  --radius-card: 24px;
  --radius-input: 16px;
  --radius-pill: 9999px;

  --shadow-card: 0 4px 0 var(--pink-soft-shadow);
  --shadow-button: 0 4px 0 var(--pink-shadow);
  --shadow-button-active: 0 1px 0 var(--pink-shadow);

  /* Animation */
  --ease-bouncy: cubic-bezier(0.34, 1.56, 0.64, 1);
}
```

---

## 8. Audit Cepat Sebelum Rilis (Checklist)

Sebelum menyelesaikan desain atau kode, pastikan semua poin ini terpenuhi:
- [ ] Apakah teks utama menggunakan warna cokelat gelap (`#4A2C36`) dan **bukan** hitam murni (`#000000`)?
- [ ] Apakah kontras antara teks dan latar belakang pink cukup jelas untuk dibaca tanpa menyipitkan mata?
- [ ] Apakah tombol memiliki efek *tactile* (border tegas + bayangan padat) dan animasi membal saat diklik?
- [ ] Apakah layout menghindari struktur 3-kolom simetris yang membosankan?
- [ ] Apakah penggunaan dekorasi imut (bintang, pita, ikon) tetap proporsional sehingga antarmuka tetap bersih dan fungsional?