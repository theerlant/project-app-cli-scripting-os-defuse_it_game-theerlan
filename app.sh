#!/bin/bash

## ## ## ## ## ## ## ##
##    Konfigurasi    ##
## ## ## ## ## ## ## ##
PICKERS=(1 2 3 4 5 6 7 8 9 0) # Pengambilan random memastikan semua nomor dipakai sekali

## ## ## ## ## ## ## ##
##   Variabel game   ##
## ## ## ## ## ## ## ##
declare -a answers=() # Jawaban yang telah digenerate
guess_count=0 # Jumlah pemain mencoba menebak


## ## ## ## ## ## ## ## ## ## ##
##   Fungsi Fitur Utama Game  ##
## ## ## ## ## ## ## ## ## ## ##
# Populate variabel answers dengan 5 nomor yang diambil secara acak dari pickers
populate_answers() {
	for (( i=0; i<5; i++ )) {
		index_count=$(( ${#PICKERS[@]} - 1 ))
		selected_index=$(( RANDOM % index_count ))

		answers+=("${PICKERS[$selected_index]}") 

		unset "PICKERS[$selected_index]"

		PICKERS=("${PICKERS[@]}")
	}
}

# Parse clue berdasarkan input
parse_guess() {
	local guesses=("$1" "$2" "$3" "$4" "$5") # Mengambil tebakan pengguna dari argument fungsi

	local correct_count=0 # Menyimpan jumlah nomor yang benar
	local misplaced_count=0 # Menyimpan jumlah nomor yang salah tempat

	for (( i=0; i<5; i++)); do
		for (( j=0; j<5; j++)); do
			if [[ ${guesses[$i]} -eq ${answers[$j]} ]]; then
				if [[ $i -eq $j ]]; then
					correct_count=$((correct_count+1))
				else
					misplaced_count=$((misplaced_count+1))
				fi
				break
			fi
		done
	done

	echo "$correct_count $misplaced_count"
} 


## ## ## ## ## ## ## ## ## ##
##   Fungsi Looping Game   ##
## ## ## ## ## ## ## ## ## ##
game_loop() {
	populate_answers

	echo "answers: " "${answers[@]}"

	while (( 1 )); do
		local guess=()

		echo -n "Masukkan 5 angka untuk menebak (tidak boleh sama)"
		while (( ${#guess[@]} < 5 )); do
			IFS= read -rsn1 key # Baca satu key
			if [[ $key =~ [0-9] ]]; then
				# Regex variable key dan hanya terima input angka
				guess+=("$key")
				echo -n "$key "
			fi
		done
		echo ""

		# Panggil fungsi untuk menghitung jumlah angka benar & salah tempat
		local result
		result="$(parse_guess "${guess[@]}")"

		# Increment jumlah menebak
		guess_count=$((guess_count+1))

		# Parsing echo dari fungsi parse_guess ke 2 variabel
		local result_arr=()
		for v in $result; do
			result_arr+=("$v")
		done
		echo "${result_arr[@]}"
		local corrects=${result_arr[0]}
		local misplaced=${result_arr[1]}

		# Output menang jika jumlah angka benar = 5; langsung keluar fungsi
		if [[ "$corrects" -eq "5" ]]; then
			echo "Selamat kamu menang!"
			echo "Total tebakan: $guess_count kali"
			return
		fi

		# Output clue jumlah angka yang benar
		if (( corrects > 0 )); then
			echo "Tebakan kamu memiliki ${corrects} angka benar"
		fi

		# Output clue jumlah angka yang salah tempat
		if (( misplaced > 0 )); then
			echo "Tebakan kamu memiliki ${misplaced} angka salah tempat"
		fi

	done
}

game_loop

