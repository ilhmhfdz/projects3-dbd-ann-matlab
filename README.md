

# 🧬 Prediksi Kasus DBD Menggunakan Artificial Neural Network (MATLAB)

Proyek ini mengembangkan model prediksi kasus **Demam Berdarah Dengue (DBD)** berbasis **Artificial Neural Network (ANN)** menggunakan bahasa pemrograman **MATLAB**. Tujuannya adalah memperkirakan jumlah kasus DBD tahunan berdasarkan variabel iklim bulanan seperti curah hujan, kelembaban, dan suhu.

Model dilatih menggunakan data historis 2014–2023 dan diuji untuk memprediksi kasus DBD tahun 2024.

---

## 📊 Teknologi & Tools

| Komponen               | Deskripsi                                   |
| ---------------------- | ------------------------------------------- |
| Bahasa pemrograman     | MATLAB                                      |
| Model Machine Learning | Feedforward Neural Network (ANN)            |
| Algoritma Training     | Levenberg–Marquardt (`trainlm`)             |
| Normalisasi            | `mapminmax`                                 |
| Arsitektur             | 36 input → 33 neuron → 18 neuron → 1 output |
| Preprocessing          | Reproducible min-max scaling                |

---

## 📁 Struktur Proyek

```
📦 dbd-ann-matlab
│
├── trainModelDBD.m          # Pelatihan model & evaluasi
├── prediksi_DBD_2025.m      # Pemanggilan model untuk prediksi lanjutan
├── Dataset.xlsx             # Data historis (iklim & jumlah kasus DBD)
├── model_ann_dbd_final.mat  # Model terlatih & parameter normalisasi
└── README.md
```

---

## 🚀 Cara Menjalankan

### 1️⃣ Jalankan Script Training

```matlab
trainModelDBD
```

Output:

* Metrik evaluasi (MSE, RMSE, MAE, R²) untuk training dan testing
* Grafik performa
* File model `model_ann_dbd_final.mat`

---

### 2️⃣ Jalankan Script Prediksi

```matlab
prediksi_DBD_2025
```

Menghasilkan prediksi kasus DBD untuk tahun berikutnya menggunakan model yang sudah tersimpan.

---

## 📈 Hasil Model

| Tahap                | Metrik                          | Hasil                            |
| -------------------- | ------------------------------- | -------------------------------- |
| Training (2014–2023) | RMSE                            | *rendah* → model fit dengan baik |
| Testing (2024)       | Prediksi mendekati nilai aktual | 👉 Model mampu generalisasi      |
| Korelasi             | R² mendekati 1                  | Akurasi prediksi tinggi          |

> Catatan: Nilai persis metrik dapat dilihat di MATLAB Command Window saat menjalankan skrip.

---

## 🎯 Tujuan Penelitian

* Mendukung perencanaan mitigasi penyakit berbasis data
* Memvalidasi hubungan iklim → peningkatan kasus DBD
* Menjadi baseline pengembangan model DBD berbasis AI

---

## 📌 Rencana Pengembangan

* [ ] Hyperparameter tuning berbasis Bayesian Optimization
* [ ] Penambahan dataset spasial (per kecamatan)
* [ ] Perbandingan model LSTM / Random Forest
* [ ] Dashboard visualisasi interaktif

---

## 📄 Lisensi

Open-source untuk tujuan riset & edukasi.
Silakan modifikasi dan kembangkan sesuai kebutuhan 🎓

---

## 👨‍💻 Pengembang

**Ilham Hafidz**
AI Engineer & Data Enthusiast
📍 Universitas Gunadarma
📬 [ilhamhafidz666@gmail.com](mailto:ilhamhafidz666@gmail.com)
