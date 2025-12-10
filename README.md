# DEFUSE IT - Game Tebak Kode

Game sederhana tebak angka berbasis terminal yang dibuat dengan Bash Script!

## Deskripsi

DEFUSE IT adalah game di mana kamu harus menebak 4 angka yang tersusun secara acak sebelum waktu habis. Setiap tebakan akan memberikan clue berapa angka yang benar dan berapa yang salah posisi. Tebak kode seri sebelum bom meledak!

## Fitur

- 4 tingkat kesulitan (Easy, Medium, Hard, Extreme)
- Timer bom yang menegangkan
- Sistem clue untuk membantu tebakan
- Tampilan ASCII art dan penggunaan ANSI Escape Kode untuk tampilan yang menarik

## Tingkat Kesulitan

Terdapat 4 tingkat kesulitan dengan aturan yang berbeda-beda

1. Easy
   - Timer: 120 detik
   - Penalti: -1 detik / tebakan
2. Medium
   - Timer: 120 detik
   - Penalti: -2 detik / tebakan
3. Hard
   - Timer: 100 detik
   - Penalti: -3 detik / tebakan
4. Extreme
   - Timer: 90 detik
   - Penalti: -4 detik / tebakan

## Cara Menjalankan

- Download file ke perangkat linux (atau menggunakan WSL dari windows)
- Jalankan kode ini ditempat kamu menaruh file
  ```bash
  chmod +x app.sh
  ./app.sh
  ```
- Ikuti petunjuk dalam game
