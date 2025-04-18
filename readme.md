# Bankir App 💳

**BankirApp** — bu foydalanuvchilarga hisoblar, tranzaksiyalar, qarzlar, investitsiyalar va kartalar bilan ishlash imkonini beruvchi qulay va xavfsiz bank ilovasiga taqlid tarzda ishlovchi tizim.

---

## 🎯 Loyihaning maqsadi:

Bankir App - foydalanuvchilarga moliyaviy operatsiyalarni boshqarish, hisobotlarni ko'rish, pul o'tkazmalari qilish va investitsiyalarni kuzatish imkoniyatlarini taqdim etadi. Ilova foydalanuvchilarga shaxsiy moliyaviy holatini boshqarishda yordam beradi.

---

## ✅ Funksional talablar:

- **Foydalanuvchi ro‘yxatdan o‘tishi, tizimga kirishi, profilini tahrirlashi va parolini tiklashi mumkin.**
- **Hisoblar**: Foydalanuvchilar o'z hisoblarini yaratish, boshqarish va tranzaksiyalarni amalga oshirishlari mumkin.
- **Tranzaksiyalar**: Foydalanuvchilar pul o'tkazmalari, balansni tekshirish, va to'lovlarni amalga oshirishi mumkin.
- **Investitsiyalar**: Foydalanuvchilar investitsiya qilish va ularning holatini ko‘rishlari mumkin.
- **Kartalar**: Foydalanuvchilar o'zlarining debet va kredit kartalarini boshqarishlari mumkin.
- **Hisob-kitoblar**: Foydalanuvchilar har bir oylik hisob-kitoblarni ko‘rish va hisob raqamlarini tekshirishlari mumkin.
- **Xavfsizlik**: JWT asosida autentifikatsiya va ikki faktorli autentifikatsiya.
- **Email xabarlar**: Parolni tiklash va tizimga kirishda foydalanuvchilarga xabar yuborish.
- **Admin paneli**: Adminlar tizimni boshqarish va foydalanuvchilarni ko‘rish imkoniyatiga ega.

---

## 📦 Nofunksional talablar:

- **Xavfsizlik**: JWT asosida autentifikatsiya va ikki faktorli autentifikatsiya.
- **Tezkorlik**: Ilova iloji boricha minimal javob vaqtida ishlashi kerak.
- **Kengayuvchanlik**: Yangi funksiyalar qo‘shishga tayyor tizim arxitekturasi.
- **Spamni oldini olish**: Bu haqida izlanishlar olib bborilmoqda.

---

## 🧩 Ma'lumotlar bazasi modellari

1. **User**
   - id,
   - name,
   - email,
   - password,
   - role (user/admin),
   - avatarUrl,
   - createdAt,
   - updatedAt;

2. **Account**
   - id,
   - userId, 
   - balance.
   - accountType (checking/savings),
   - createdAt,
   - updatedAt;

3. **Transaction**
   - id, 
   - fromAccountId,
   - toAccountId,
   - amount,
   - transactionDate,
   - status (completed/pending),
   - createdAt,
   - updatedAt;

4. **Repayment**
   - id,
   - amount,
   - repaymentDate,
   - createdAt,
   - updatedAt;

5. **Investment**
   - id,
   - userId,
   - accountId,
   - investmentAmount,
   - investmentDate,
   - status (active/closed),
   - createdAt,
   - updatedAt;

6. **Card**
   - id,
   - userId,
   - accountId,
   - cardType (debit/credit),
   - cardNumber,
   - expirationDate,
   - createdAt,
   - updatedAt;

---

## 🌟 Qo'shimcha funksiyalar:

- **Notification tizimi**: Tranzaksiyalar yoki qarz to'lovlari haqida bildirishnomalar.
- **Dark mode**: Qorong'u rejim qo'llab-quvvatlashi.
- **Hisob-kitoblar va hisobotlar**: Oylik moliyaviy hisobotlar va xarajatlar tahlili.

## 🛠️ Texnologiyalar:



- **Ma'lumotlarni qidirish**: Elasticsearch
---

## 🏗️ Loyiha bo'yicha kelgusidagi rejalar:

1. Admin panelni yanada kengaytirish va yaxshilash.
2. Kredit va investitsiya variantlari uchun ko'p tilli qo'llab-quvvatlash.
3. Foydalanuvchi tajribasini oshirish uchun optimallashtirish.
4. Hisoblar bo‘yicha integratsiya (masalan, banklar bilan).
5. Mobil ilova yaratish.

---

## 💡 Foydalanuvchilarni boshqarish:

Adminlar foydalanuvchi ro‘yxatini ko‘rib chiqishi, foydalanuvchilarni bloklashi yoki ularga huquqlar berishi mumkin.
