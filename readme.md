# 🏦 Bankist App - Banking Server 💳

**Bankist App** — bu kichik yoki o‘rta hajmdagi tijorat banklari uchun yaratilgan backend tizimi bo‘lib, foydalanuvchilarga moliyaviy hisoblar, tranzaksiyalar, qarzlar, investitsiyalar, kartalar va boshqa operatsiyalarni boshqarish imkonini beradi.

---

## 🎯 Loyihaning maqsadi:

Bankist App foydalanuvchilarga o‘z bank hisoblarini xavfsiz, tezkor va qulay boshqarish imkonini beruvchi backend platformani yaratishni maqsad qilgan. Bu tizim moliyaviy xizmatlarni raqamlashtirish orqali mijozlar tajribasini oshiradi.

---

## ✅ Asosiy funksiyalar:

- 🔐 **Foydalanuvchi autentifikatsiyasi**: JWT orqali tizimga kirish, ro‘yxatdan o‘tish, parolni tiklash.
- 💰 **Hisoblar**: Yangi hisob yaratish, mavjud balansni ko‘rish, hisob turlarini boshqarish.
- 🔄 **Tranzaksiyalar**: Pul o‘tkazmalari, balanslararo operatsiyalar.
- 📈 **Investitsiyalar**: Investitsiya kiritish va ularning holatini monitoring qilish.
- 💳 **Kartalar**: Kredit va debet kartalarni boshqarish.
- 📊 **Hisobotlar**: Moliyaviy hisob-kitoblar va foydalanuvchi faoliyati haqida hisobotlar.
- 📬 **Email xabarlar**: Xavfsizlik va bildirishnomalar uchun elektron pochta xabarlari.
- 🛠 **Admin panel**: Foydalanuvchilarni kuzatish va boshqarish imkoniyati.

---

## 📦 Nofunksional talablar:

- 🔒 **Xavfsizlik**: JWT va 2FA (ikki faktorli autentifikatsiya) orqali himoya.
- ⚡ **Samaradorlik**: Yaxshi optimallashtirilgan va tez ishlovchi tizim.
- 🧩 **Kengayuvchanlik**: Yangi imkoniyatlar uchun mos arxitektura.
- 🚫 **Spamdan himoya**: Email va SMS orqali spamga qarshi chora-tadbirlar.

---

## 🧾 Ma'lumotlar bazasi modellari

### 👤 `User`
| Maydon          | Tip                        |
|-----------------|----------------------------|
| id              | int (Primary Key)          |
| name            | varchar(255)               |
| email           | varchar(255, Unique)       |
| password        | varchar(255)               |
| role            | enum('user', 'admin')      |
| avatarUrl       | varchar(255, nullable)     |
| createdAt       | timestamp                  |
| updatedAt       | timestamp                  |

---

### 🏦 `Account`
| Maydon          | Tip                              |
|-----------------|----------------------------------|
| id              | int (Primary Key)                |
| userId          | int (Foreign Key → User.id)      |
| balance         | decimal                          |
| accountType     | enum('checking', 'savings')      |
| createdAt       | timestamp                        |
| updatedAt       | timestamp                        |

---

### 🔄 `Transaction`
| Maydon          | Tip                                  |
|-----------------|--------------------------------------|
| id              | int (Primary Key)                    |
| fromAccountId   | int (Foreign Key → Account.id)       |
| toAccountId     | int (Foreign Key → Account.id)       |
| amount          | decimal                              |
| transactionDate | timestamp                            |
| status          | enum('completed', 'pending')         |
| createdAt       | timestamp                            |
| updatedAt       | timestamp                            |

---

### 💸 `Repayment`
| Maydon          | Tip          |
|-----------------|--------------|
| id              | int (Primary Key) |
| amount          | decimal      |
| repaymentDate   | timestamp    |
| createdAt       | timestamp    |
| updatedAt       | timestamp    |

---

### 📈 `Investment`
| Maydon            | Tip                                  |
|-------------------|--------------------------------------|
| id                | int (Primary Key)                    |
| userId            | int (Foreign Key → User.id)          |
| accountId         | int (Foreign Key → Account.id)       |
| investmentAmount  | decimal                              |
| investmentDate    | timestamp                            |
| status            | enum('active', 'closed')             |
| createdAt         | timestamp                            |
| updatedAt         | timestamp                            |

---

### 💳 `Card`
| Maydon          | Tip                                  |
|-----------------|--------------------------------------|
| id              | int (Primary Key)                    |
| userId          | int (Foreign Key → User.id)          |
| accountId       | int (Foreign Key → Account.id)       |
| cardType        | enum('debit', 'credit')              |
| cardNumber      | varchar(255, Unique)                 |
| expirationDate  | date                                 |
| createdAt       | timestamp                            |
| updatedAt       | timestamp                            |

---

## 🌟 Qo'shimcha funksiyalar

- 🔔 **Bildirishnomalar**: Tranzaksiyalar, investitsiyalar va qarzlar bo‘yicha real vaqtda xabarnomalar.
- 🌙 **Dark Mode**: Qorong‘i rejimni qo‘llab-quvvatlash.
- 📉 **Moliyaviy tahlil**: Oylik sarf-harajatlar bo‘yicha hisobotlar.
- 🚫 **Spam nazorati**: Soxta foydalanuvchi va xabarlarga qarshi himoya.

---

## 🛠️ Texnologiyalar

| Yo‘nalish            | Texnologiyalar                           |
|----------------------|-------------------------------------------|
| Backend              | Node.js, Express.js                       |
| Ma’lumotlar bazasi   | MySQL yoki PostgreSQL                     |
| Autentifikatsiya     | JWT, Bcrypt.js                            |
| Fayl yuklash         | Multer                                    |
| Email xabarlar       | Nodemailer                                |
| Xavfsizlik           | Two-Factor Authentication (2FA)           |
| Qidiruv              | Elasticsearch (kelgusida)                 |

---

## 🏗️ Kelajakdagi rejalar

1. 🧮 Admin panelni kengaytirish va statistik tahlillarni qo‘shish.
2. 🌍 Ko‘p tilli qo‘llab-quvvatlash (Multi-language).
3. 📱 Mobil ilovalar bilan sinxronlash.
4. 🔌 Boshqa bank API tizimlari bilan integratsiya.
5. 🤖 AI asosida moliyaviy maslahatlar tizimi.


---

> Ushbu loyiha o‘quv maqsadida ishlab chiqilgan bo‘lib, haqiqiy bank muhitida ishlatishdan oldin qo‘shimcha xavfsizlik tekshiruvlari o‘tkazilishi tavsiya etiladi.
