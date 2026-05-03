# Diplom ishi: Boshlang'ich sinflar uchun texnologiya fanini interaktiv tarzda o'rgatuvchi mobil ilova

**Muassasa:** Toshkent axborot texnologiyalari universiteti  
**Yo'nalish:** Axborot kommunikatsiya texnologiyalari sohasida kasb-ta'lim  
**Mavzu:** Boshlang'ich sinflar uchun texnologiya fanini interaktiv tarzda o'rgatuvchi mobil ilova yaratish

---

## 1. Ilovaning maqsadi va vazifasi

Boshlang'ich sinf o'quvchilari (1–4-sinflar) uchun texnologiya fanini qiziqarli, interaktiv va vizual tarzda o'rgatish. O'quvchilarning mustaqil o'rganish qobiliyatini rivojlantirish va darsni gamifikatsiya orqali samarali qilish.

---

## 2. Asosiy funksionalliklar

### 2.1 Foydalanuvchi tizimi (User Management)

- **Ro'yxatdan o'tish / Kirish**
  - O'quvchi profili (ism, sinf, yosh, avatar tanlash)
  - Ota-ona / o'qituvchi nazorat paneli
  - Parolsiz kirish (PIN-kod yoki rasm orqali — kichik yoshlar uchun)

- **Profil sozlamalari**
  - Avatar va ism o'zgartirish
  - Sinf va daraja tanlash (1–4-sinf)
  - Til tanlash (O'zbek, Rus)

---

### 2.2 O'quv modullari (Learning Modules)

- **Darslar bo'limi**
  - Mavzu bo'yicha qisqa animatsiyali video darslar
  - Interaktiv slaydlar (rasmlar, sxemalar, diagrammalar)
  - Ovozli izoh (audio narration) — o'qiy olmagan bolalar uchun
  - Bosqichma-bosqich tushuntirish (step-by-step)

- **Mavzular ro'yxati (Texnologiya fani bo'yicha)**
  - Qog'oz bilan ishlash (origami, kesish, yopish)
  - Loydan buyum yasash
  - Tabiiy materiallar bilan ishlash
  - Tikish va to'qish asoslari
  - Oddiy konstruktorlar va modellashtirish
  - Rasm chizish va bezash texnikasi
  - Ekologiya va qayta ishlash (recycle)

---

### 2.3 Interaktiv topshiriqlar (Interactive Tasks)

- **Test va viktorinalar**
  - Ko'p tanlovli savollar (A, B, C, D)
  - Rasmni moslashtirish (drag-and-drop)
  - To'ldirish / juftlashtirish mashqlari

- **Amaliy topshiriqlar**
  - Bosqichma-bosqich yasash ko'rsatmasi (animated guide)
  - Fotosuratni yuklash — bajarilgan ishni ko'rsatish imkoniyati
  - O'qituvchi / ota-ona tomonidan baholash

- **Mini-o'yinlar (Educational Games)**
  - Puzzle (rasm yig'ish)
  - Moslashtirish o'yini (matching game)
  - Tartiblash o'yini (sorting/sequencing)
  - Qurilish simulyatori (virtual konstruktor)

---

### 2.4 Gamifikatsiya tizimi (Gamification)

- **Yutuqlar va mukofotlar**
  - Yulduz va badge (nishon) tizimi
  - Har bir darsni tugatganda animatsiyali tabriklash
  - "Kun qahramoni", "Eng faol o'quvchi" unvonlari

- **Progress (jarayon) kuzatuvi**
  - Har bir mavzu bo'yicha progress bar
  - Haftalik / oylik hisobot
  - O'quvchining darajasi (level) oshib borishi

- **Reyting jadvali (Leaderboard)**
  - Sinf ichida reyting
  - Do'stlar bilan raqobat (ixtiyoriy)

---

### 2.5 O'qituvchi va ota-ona paneli

- **O'qituvchi paneli**
  - O'quvchilar ro'yxati va ularning natijalari
  - Qo'shimcha topshiriq berish imkoniyati
  - Dars materiallarini ko'rish va boshqarish
  - Statistik hisobotlar (kim qanday mavzuni o'tdi)

- **Ota-ona paneli**
  - Farzandining kunlik faoliyatini kuzatish
  - Ekran vaqtini cheklash (parental control)
  - Bildirishnomalar (topshiriq bajardimi, yangi dars bor)

---

### 2.6 Multimedia va kontent

- **Audio-vizual materiallar**
  - Animatsiyali multimedia darslar
  - Qo'shiqli mnemonik ko'rsatmalar (yodlash uchun)
  - Real hayotdan video namunalar (yasash jarayoni)

- **Interaktiv daftar (Digital Notebook)**
  - O'quvchi o'z yozuvlarini qoldirishi mumkin
  - Rasm chizish va saqlash (draw & save)
  - Bajarilgan ishlar galereyasi

---

### 2.7 Bildirishnomalar tizimi (Notifications)

- Yangi dars yoki topshiriq borligi haqida xabar
- Kunlik eslatma ("Bugun darsni o'tdingizmi?")
- O'qituvchi xabarlari

---

### 2.8 Qidiruv va navigatsiya

- Mavzu bo'yicha qidiruv
- Sinf (1, 2, 3, 4) bo'yicha filtrlash
- "Davom etish" — oxirgi o'tilgan darsga qaytish
- "Sevimlilar" — saralangan darslar

---

### 2.9 Oflayn rejim (Offline Mode)

- Internetnsiz ishlash uchun darslarni yuklab olish
- Kesh xotirada saqlash
- Onlayn ulanishda avtomatik sinxronizatsiya

---

### 2.10 Til va imkoniyat (Accessibility)

- O'zbek va Rus tillarida interfeys
- Shrift o'lchamini kattalashtirish imkoniyati
- Yuqori kontrast rejimi (ko'rish qiyinchiligiga ega foydalanuvchilar uchun)
- Bolalarga mos sodda interfeys (child-friendly UI)

---

## 3. Texnik talablar

| Parametr | Qiymat |
|----------|--------|
| Platforma | Android (asosiy), iOS (kelajak) |
| Dasturlash tili | Flutter (Dart) yoki React Native |
| Backend | Firebase yoki Node.js + MongoDB |
| Ma'lumotlar bazasi | Firebase Firestore / SQLite (oflayn) |
| Minimum Android versiya | Android 6.0 (API 23) |
| Dizayn | Material Design 3 (bolalarga mos) |

---

## 4. Ilovaning tuzilmasi (App Architecture)

```
mobil-ilova/
├── Kirish ekrani (Splash / Onboarding)
├── Autentifikatsiya (Login / Register)
├── Bosh sahifa (Home)
│   ├── Darslar bo'limi
│   ├── O'yinlar bo'limi
│   ├── Mening natijalarim
│   └── Sozlamalar
├── Dars ekrani
│   ├── Video / Animatsiya
│   ├── Interaktiv topshiriq
│   └── Natija / Mukofot
├── O'qituvchi / Ota-ona paneli
└── Profil
```

---

## 5. Foydalanuvchi toifalari

| Toifa | Imkoniyatlar |
|-------|-------------|
| O'quvchi (1–4-sinf) | Dars ko'rish, topshiriq bajarish, o'yin o'ynash |
| O'qituvchi | O'quvchilarni boshqarish, natijalarni kuzatish |
| Ota-ona | Nazorat, hisobot, vaqt cheklash |
| Admin | Kontent boshqaruvi, foydalanuvchilar boshqaruvi |

---

## 6. Kutilayotgan natijalar

- O'quvchilarning texnologiya faniga qiziqishini oshirish
- Vizual va interaktiv o'rganish orqali bilimni mustahkamlash
- O'qituvchining ish yukini kamaytirish
- Ota-onalar bilan muloqotni yaxshilash
- Raqamli savodxonlikni boshlang'ich sinflardan shakllantirish

---

*Diplom ishi — TATU, AKT sohasida kasb-ta'lim yo'nalishi*
