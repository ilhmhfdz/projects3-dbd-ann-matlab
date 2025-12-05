%% ========================================================================
% SCRIPT PELATIHAN MODEL ANN UNTUK PREDIKSI KASUS DBD
% Versi: 2.0 (Disempurnakan)
% Deskripsi:
% Script ini melatih Jaringan Saraf Tiruan (ANN) untuk memprediksi
% jumlah kasus DBD tahunan berdasarkan data iklim bulanan (36 fitur).
% =========================================================================

%% 1. PEMBERSIHAN DAN KONFIGURASI AWAL
clc;            % Bersihkan Command Window
clear;          % Hapus semua variabel dari workspace
close all;      % Tutup semua figure/plot
warning on;     % Tampilkan warning untuk debugging
rng('default'); % Atur random seed untuk hasil yang konsisten


%% 2. MEMUAT DAN MEMPROSES DATA (VERSI PERBAIKAN)
disp('1. Memuat dan memproses data...');

%  'readtable' lebih modern dan robust
try
    dataTable = readtable('Dataset.xlsx');
catch ME
    error('Gagal membaca file Dataset.xlsx. Pastikan file berada di direktori yang sama. Error: %s', ME.message);
end

% --- PERBAIKAN UTAMA: MEMILIH KOLOM YANG BENAR ---
% Mereplikasi logika xlsread('...','B2:AL13')
% Kita pilih data dari kolom ke-2 (B) sampai kolom ke-38 (AL) dari tabel
% Asumsi: Data 2014-2024 berada di baris 1-11 dari tabel (setelah header)
data_matrix = table2array(dataTable(1:11, 2:38));
% 'data_matrix' sekarang berisi 37 kolom, sama persis seperti output xlsread lama.
% Kolom ke-37 dari 'data_matrix' adalah kasus DBD.
% ----------------------------------------------------

% --- PEMISAHAN DATA LATIH (TRAINING) DAN DATA UJI (TESTING) ---
% Logika ini sekarang akan bekerja dengan benar karena 'data_matrix' sudah tepat.
X_train = data_matrix(1:10, 1:36);     % Input latih: iklim 2014–2023
Y_train = data_matrix(1:10, 37);      % Target latih: DBD 2014–2023 (SEKARANG SUDAH BENAR)

X_test = data_matrix(11, 1:36);       % Input uji: iklim 2024
Y_test = data_matrix(11, 37);       % Target uji: DBD 2024 (SEKARANG SUDAH BENAR)

disp('   Pemisahan data selesai: 10 tahun data latih, 1 tahun data uji.');

%% 3. NORMALISASI DATA
% Normalisasi data ke rentang [0, 1] sangat penting untuk performa ANN.
% Kita menggunakan fungsi 'mapminmax' yang sudah disediakan MATLAB.

disp('2. Melakukan normalisasi data...');
[X_train_norm, ps_input] = mapminmax(X_train');
[Y_train_norm, ps_target] = mapminmax(Y_train');

% Normalisasi data uji HARUS menggunakan parameter dari data latih (ps_input)
X_test_norm = mapminmax('apply', X_test', ps_input);

%% 4.
%% 4.  MEMBANGUN ARSITEKTUR JARINGAN SARAF TIRUAN (ANN) STRATEGI BARU: MENGGUNAKAN 'trainlm' DENGAN REGULARISASI MANUAL
disp('3. Membangun arsitektur dengan regularisasi manual (msereg)...');

% Kita coba arsitektur yang cukup besar karena trainlm lebih fleksibel
hiddenLayer1Size = 33;
hiddenLayer2Size = 18;
net = feedforwardnet([hiddenLayer1Size hiddenLayer2Size]);

% --- KONFIGURASI BARU YANG PALING PENTING ---
net.trainFcn = 'trainlm'; % Levenberg-Marquardt
net.performFcn = 'msereg'; % MENGGUNAKAN MEAN SQUARED ERROR DENGAN REGULARISASI

% Atur parameter regularisasi. Nilai antara 0 dan 1.
% Semakin mendekati 1, semakin fokus pada error (mirip trainlm murni, risiko overfitting).
% Semakin mendekati 0, semakin fokus pada regularisasi (menekan bobot, risiko underfitting).
% Mari kita mulai dengan nilai penyeimbang.
net.performParam.regularization = 0.4; % Coba nilai awal 0.2

% --------------------------------------------------
% Fungsi aktivasi kita gunakan tansig yang lebih stabil
net.layers{1}.transferFcn = 'tansig';
net.layers{2}.transferFcn = 'tansig';
net.layers{3}.transferFcn = 'purelin';
net.plotFcns = {'plotperform', 'plottrainstate', 'ploterrhist', 'plotregression'};
%% 5. MELATIH JARINGAN
disp('4. Memulai pelatihan jaringan...');
[net, tr] = train(net, X_train_norm, Y_train_norm);
disp('   Pelatihan selesai.');

% Simpan jaringan terbaik berdasarkan performa validasi
best_net = net;

%% 6. EVALUASI MODEL PADA DATA LATIH
disp('5. Mengevaluasi performa model pada data latih...');

% Simulasi pada data latih
Y_train_pred_norm = best_net(X_train_norm);

% De-normalisasi hasil prediksi untuk kembali ke skala asli
Y_train_pred = mapminmax('reverse', Y_train_pred_norm, ps_target);

% Hitung metrik evaluasi
mse_train = mean((Y_train' - Y_train_pred).^2);
rmse_train = sqrt(mse_train);
mae_train = mean(abs(Y_train' - Y_train_pred));
R2_train = 1 - (sum((Y_train' - Y_train_pred).^2) / sum((Y_train' - mean(Y_train')).^2));

disp('   --- Performa pada Data Latih (2014-2023) ---');
disp(['   MSE      : ', num2str(mse_train)]);
disp(['   RMSE     : ', num2str(rmse_train)]);
disp(['   MAE      : ', num2str(mae_train)]);
disp(['   R-squared: ', num2str(R2_train)]);

%% 7. PENGUJIAN MODEL PADA DATA UJI (TAHUN 2024)
disp('6. Menguji model pada data uji (2024)...');

% Simulasi pada data uji yang belum pernah dilihat
Y_test_pred_norm = best_net(X_test_norm);

% De-normalisasi hasil prediksi
Y_test_pred = mapminmax('reverse', Y_test_pred_norm, ps_target);

% Hitung metrik evaluasi pada data uji
mse_test = mean((Y_test' - Y_test_pred).^2);
rmse_test = sqrt(mse_test);
mae_test = mean(abs(Y_test' - Y_test_pred));
R2_test = 1 - (sum((Y_test' - Y_test_pred).^2) / sum((Y_test' - mean(Y_test')).^2));

disp('   --- Performa pada Data Uji (2024) ---');
disp(['   Kasus DBD Aktual 2024  : ', num2str(Y_test)]);
disp(['   Prediksi Kasus DBD 2024: ', num2str(round(Y_test_pred))]);
disp(['   MSE      : ', num2str(mse_test)]);
disp(['   RMSE     : ', num2str(rmse_test)]);
disp(['   MAE      : ', num2str(mae_test)]);
disp(['   R-squared: ', num2str(R2_test)]);

%% 8. VISUALISASI HASIL
disp('7. Menampilkan hasil visualisasi untuk laporan...');

% Asumsi variabel ini sudah ada dari langkah sebelumnya:
% Y_train, Y_test                 -> Data kasus aktual.
% Y_train_pred_avg, Y_test_pred_avg -> Prediksi dari model (jika pakai ensemble).
% Jika tidak pakai ensemble, ganti _avg menjadi _pred biasa (misal: Y_train_pred).

% =========================================================================
% GRAFIK 1: PERBANDINGAN DERET WAKTU (DATA LATIH)
% =========================================================================
% Grafik ini menunjukkan seberapa baik model mengikuti pola historis.
tahun_latih = 2014:2023;
figure('Name', 'Grafik Performa Model pada Data Latih', 'NumberTitle', 'off', 'Color', 'white');

plot(tahun_latih, Y_train, 'r-s', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'r'); 
hold on;
plot(tahun_latih, Y_train_pred, 'b--o', 'LineWidth', 1.5, 'MarkerSize', 8); % Ganti Y_train_pred_avg jika perlu
hold off;

grid on;
title('Perbandingan Kasus DBD Aktual vs. Prediksi Model (Data Latih 2014-2023)', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Tahun', 'FontSize', 12);
ylabel('Jumlah Kasus DBD', 'FontSize', 12);
legend('Target (Aktual)', 'Prediksi Model', 'Location', 'northwest', 'FontSize', 11);
set(gca, 'FontSize', 11);
xlim([2013.5 2023.5]);

% =========================================================================
% GRAFIK 2: GRAFIK BATANG PERBANDINGAN (DATA UJI)
% =========================================================================
% Grafik ini sangat efektif untuk menunjukkan performa pada satu titik data uji.
figure('Name', 'Hasil Uji Coba Model 2024', 'NumberTitle', 'off', 'Color', 'white');

data_perbandingan = [Y_test, Y_test_pred]; % Ganti Y_test_pred_avg jika perlu
kategori = categorical({'Target (Aktual)', 'Prediksi Model'});
kategori = reordercats(kategori, {'Target (Aktual)', 'Prediksi Model'});

b = bar(kategori, data_perbandingan, 0.5);

grid on;
title('Hasil Prediksi vs. Target Aktual untuk Tahun 2024', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Jumlah Kasus DBD', 'FontSize', 12);
set(gca, 'FontSize', 11);

b.FaceColor = 'flat';
b.CData(1,:) = [0.8500 0.3250 0.0980]; % Warna oranye untuk Aktual
b.CData(2,:) = [0 0.4470 0.7410];      % Warna biru untuk Prediksi

xtips = b.XEndPoints;
ytips = b.YEndPoints;
labels = string(round(b.YData));
text(xtips, ytips, labels, 'HorizontalAlignment','center', 'VerticalAlignment','bottom', 'FontSize', 12, 'FontWeight', 'bold');
ylim([0, max(data_perbandingan) * 1.15]);

% =========================================================================
% GRAFIK 3: PLOT REGRESI (KORELASI AKTUAL VS PREDIKSI)
% =========================================================================
% Grafik standar akademik untuk melihat kualitas korelasi model.
figure('Name', 'Analisis Plot Regresi', 'NumberTitle', 'off', 'Color', 'white');

scatter(Y_train, Y_train_pred, 75, 'filled', 'MarkerFaceColor', [0 0.4470 0.7410], 'MarkerEdgeColor', 'k'); % Ganti Y_train_pred_avg jika perlu
hold on;

min_val = min([Y_train; Y_train_pred']); % Ganti Y_train_pred_avg jika perlu
max_val = max([Y_train; Y_train_pred']); % Ganti Y_train_pred_avg jika perlu
ref_line = linspace(min_val, max_val, 100);
plot(ref_line, ref_line, 'k--', 'LineWidth', 2);

hold off;

grid on;
axis equal;
title('Analisis Regresi: Korelasi Target vs. Prediksi (Data Latih)', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Kasus DBD Aktual', 'FontSize', 12);
ylabel('Kasus DBD Prediksi', 'FontSize', 12);
legend('Data Prediksi vs Aktual', 'Garis Prediksi Sempurna (Y=X)', 'Location', 'northwest', 'FontSize', 11);
set(gca, 'FontSize', 11);

%% 9. MENYIMPAN MODEL DAN PARAMETER NORMALISASI
disp('8. Menyimpan model terlatih...');
% Simpan jaringan dan parameter normalisasi untuk digunakan nanti
save('model_ann_dbd_final.mat', 'best_net', 'ps_input', 'ps_target');
fprintf('   Model dan parameter normalisasi telah disimpan sebagai: model_ann_dbd_final.mat\n');

disp('Proses selesai.');D