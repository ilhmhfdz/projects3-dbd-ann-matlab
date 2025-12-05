%% ========================================================================
% SCRIPT PREDIKSI KASUS DBD TAHUN 2025
% Versi: 1.0
% Deskripsi:
% Script ini menggunakan model ANN yang sudah dilatih sebelumnya
% untuk memprediksi jumlah kasus DBD pada tahun 2025 berdasarkan
% input data iklim tahun 2025.
% =========================================================================

%% 1. PEMBERSIHAN DAN KONFIGURASI AWAL
clc;            % Bersihkan Command Window
clear;          % Hapus semua variabel dari workspace
close all;      % Tutup semua figure/plot
warning off all; % Matikan warning yang tidak perlu

%% 2. MEMUAT MODEL DAN PARAMETER
disp('1. Memuat model ANN yang sudah dilatih...');

try
    % Muat model (best_net) dan parameter normalisasi (ps_input, ps_target)
    load('model_ann_dbd_final.mat', 'best_net', 'ps_input', 'ps_target');
    disp('   Model dan parameter normalisasi berhasil dimuat.');
catch ME
    error('Gagal memuat file model_ann_dbd_final.mat. Pastikan file ini ada di direktori yang sama dengan script ini. Error: %s', ME.message);
end

%% 3. MEMUAT DATA INPUT UNTUK TAHUN 2025
disp('2. Memuat data iklim untuk tahun 2025...');

% NAMA FILE: Pastikan nama file ini sesuai dengan file yang Anda siapkan.
nama_file_input = 'Data_Iklim_2025.xlsx';

try
    % Membaca data dari file Excel.
    % Asumsi data iklim 2025 (36 kolom) berada di baris pertama.
    data_2025_table = readtable(nama_file_input);
    
    % Konversi ke matriks. Ambil 36 kolom pertama.
    X_2025 = table2array(data_2025_table(1, 1:36));
    
    % Validasi ukuran data input
    if size(X_2025, 2) ~= 36
        error('Data input 2025 tidak memiliki 36 kolom. Harap periksa kembali file Excel Anda.');
    end
    
    disp('   Data iklim 2025 berhasil dimuat.');
catch ME
    error('Gagal memuat file %s. Pastikan file ada dan formatnya benar. Error: %s', nama_file_input, ME.message);
end

%% 4. MELAKUKAN PREDIKSI
disp('3. Melakukan prediksi kasus DBD untuk tahun 2025...');

% Langkah 4a: Normalisasi data input 2025 menggunakan parameter (ps_input) dari data latih
% Transpose (X_2025') diperlukan karena mapminmax bekerja pada baris.
X_2025_norm = mapminmax('apply', X_2025', ps_input);

% Langkah 4b: Lakukan simulasi (prediksi) dengan jaringan yang sudah dilatih
Y_2025_pred_norm = best_net(X_2025_norm);

% Langkah 4c: De-normalisasi hasil prediksi untuk mendapatkan nilai asli kasus DBD
Y_2025_pred = mapminmax('reverse', Y_2025_pred_norm, ps_target);

disp('   Prediksi selesai.');

%% 5. TAMPILKAN HASIL AKHIR
% Tampilkan hasil prediksi dengan format yang jelas di Command Window.

fprintf('\n=======================================================\n');
fprintf('   HASIL PREDIKSI KASUS DBD TAHUN 2025\n');
fprintf('=======================================================\n');
fprintf('Prediksi jumlah kasus DBD untuk tahun 2025 adalah: %d kasus\n', round(Y_2025_pred));
fprintf('=======================================================\n\n');

%% 6. VISUALISASI HASIL PREDIKSI 2025 DENGAN KONTEKS HISTORIS
disp('4. Membuat visualisasi hasil prediksi...');

% --- Langkah 6a: Muat kembali data historis untuk perbandingan ---
% Kita perlu data aktual dari 2014-2024 untuk memberikan konteks.
try
    dataTableHistoris = readtable('Dataset.xlsx');
    % Ambil data kasus DBD dari kolom AL (kolom ke-37 dari kolom B)
    data_historis = table2array(dataTableHistoris(1:11, 38)); % Kolom AL adalah kolom ke-38 jika dihitung dari A
catch ME
    warning('Gagal memuat data historis untuk visualisasi. Grafik tidak akan ditampilkan. Error: %s', ME.message);
    % Jika gagal, cukup hentikan bagian visualisasi ini dan jangan buat error.
    return;
end

% --- Langkah 6b: Siapkan data untuk plot ---
tahun_historis = 2014:2024;
tahun_prediksi = 2025;
semua_tahun = [tahun_historis, tahun_prediksi];

% Gabungkan data aktual dengan hasil prediksi
data_plot = [data_historis; round(Y_2025_pred)];

% --- Langkah 6c: Buat Grafik Batang ---
figure('Name', 'Proyeksi Kasus DBD Tahun 2025', 'NumberTitle', 'off', 'Color', 'white');

% Plot data historis
b = bar(semua_tahun, data_plot, 0.6); % 0.6 adalah lebar bar
hold on;

% Beri warna berbeda untuk bar prediksi 2025
b.FaceColor = 'flat';
% Beri warna biru untuk 11 bar pertama (data historis)
for i = 1:11
    b.CData(i,:) = [0 0.4470 0.7410];
end
% Beri warna merah/oranye untuk bar terakhir (prediksi 2025)
b.CData(12,:) = [0.8500 0.3250 0.0980];

% --- Langkah 6d: Mempercantik dan Memberi Label ---
grid on;
title('Proyeksi Kasus DBD Tahun 2025 Berdasarkan Data Historis', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Tahun', 'FontSize', 12);
ylabel('Jumlah Kasus DBD', 'FontSize', 12);
set(gca, 'FontSize', 11, 'XTick', semua_tahun);
xtickangle(45); % Miringkan label tahun agar tidak bertabrakan

% Menambahkan label angka di atas bar prediksi 2025
pred_label = string(round(Y_2025_pred));
text(tahun_prediksi, round(Y_2025_pred), pred_label, 'HorizontalAlignment','center', 'VerticalAlignment','bottom', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'black');

% Membuat legenda kustom
h = zeros(2, 1);
h(1) = patch(NaN, NaN, [0 0.4470 0.7410]);      % Handle untuk warna biru
h(2) = patch(NaN, NaN, [0.8500 0.3250 0.0980]); % Handle untuk warna oranye
legend(h, 'Data Historis (2014-2024)', 'Prediksi 2025', 'Location', 'northwest', 'FontSize', 11);

ylim([0, max(data_plot) * 1.15]); % Atur batas atas sumbu y
disp('   Visualisasi selesai ditampilkan.');