#!/bin/bash

## ## ## ## ## ## ## ##
##    Konfigurasi    ##
## ## ## ## ## ## ## ##
SECOND_PER_FRAME=0.03 # Jarak antar render, mensimulasikan game.
FRAME_PER_SECOND=30 # Jumlah render. Digunakan mengurangi timer bomb karena bash tidak bisa desimal

DIFFICULTY_PENALTY=(1 2 3 4) # 4 Mode Kesulitan. Penalti (pengurangan waktu) setiap kali mencoba menebak
DIFFICULTY_TIMER=(120 120 100 90) # 4 Mode Kesulitan. Timer bomb

## ## ## ## ## ## ## ##
##   Variabel game   ##
## ## ## ## ## ## ## ##
declare -a answers=() # Jawaban yang telah digenerate

timer=0 # Timer bomb berdasarkan difficulty
penalty=0 # Penalty berdasarkan difficulty


## ## ## ## ## ## ## ## ## ## ##
##   Fungsi Fitur Utama Game  ##
## ## ## ## ## ## ## ## ## ## ##
# Populate variabel answers dengan 5 nomor yang diambil secara acak dari pickers
populate_answers() {
	local PICKERS=(1 2 3 4 5 6 7 8 9 0) # Pengambilan random memastikan semua nomor dipakai sekali

	# Ambil sampai dapat 4 angka
	for (( i=0; i<4; i++ )) {
		index_count=$(( ${#PICKERS[@]} - 1 ))
		selected_index=$(( RANDOM % index_count ))

		answers+=("${PICKERS[$selected_index]}") 

		unset "PICKERS[$selected_index]"

		PICKERS=("${PICKERS[@]}")
	}
}

# Parse clue berdasarkan input
parse_guess() {
	local guesses=("$1" "$2" "$3" "$4") # Mengambil tebakan pengguna dari argument fungsi

	local correct_count=0 # Menyimpan jumlah nomor yang benar
	local misplaced_count=0 # Menyimpan jumlah nomor yang salah tempat

	# Cek array guess jika ada angka yang sama di array answer
	for (( i=0; i<4; i++)); do
		for (( j=0; j<4; j++)); do
			if [[ ${guesses[$i]} -eq ${answers[$j]} ]]; then
				if [[ $i -eq $j ]]; then
				# Jika ada dan posisi index sama
					correct_count=$((correct_count+1))
				else
				# Jika ada tapi posisi index beda
					misplaced_count=$((misplaced_count+1))
				fi
				break
			fi
		done
	done

	# Output hasil parsing dipisah spasi agar mudah di looping
	echo "$correct_count $misplaced_count"
} 


## ## ## ## ## ## ## ## ## ##
##   Fungsi Looping Game   ##
## ## ## ## ## ## ## ## ## ##

# Rendering template UI dasar
render_base_ui() {
	echo -ne "\e[2J"
	echo -ne "\e[H"
	echo -ne "\e[1;31m"
	echo -e "███████▄    █████████   █████████   ██      ██    ▄███████   █████████        ██████   ██████████   ██"
	echo -e "██    ▀██   ██          ██          ██      ██   ██▀         ██                 ██         ██       ██"
	echo -e "██     ██   ██          ██          ██      ██   ██▄         ██                 ██         ██       ██"
	echo -e "██     ██   █████████   █████████   ██      ██    ▀██████▄   █████████          ██         ██       ██"
	echo -e "██     ██   ██          ██          ██      ██         ▀██   ██                 ██         ██       ██"
	echo -e "██    ▄██   ██          ██          ██▄    ▄██         ▄██   ██                 ██         ██         "
	echo -e "███████▀    █████████   ██           ▀██████▀    ███████▀    █████████        ██████       ██       ██"
	echo -e "\e[0m"
	echo -e "┌────────────────────────────────────────────────────────────────────────────────────────────────────┐"
	echo -e "│                                                                                                    │"
	echo -e "│                                                                                                    │"
	echo -e "│                                                                                                    │"
	echo -e "│                                                                                                    │"
	echo -e "│                                                                                                    │"
	echo -e "│                                                                                                    │"
	echo -e "│                                                                                                    │"
	echo -e "│                                                                                                    │"
	echo -e "│                                                                                                    │"
	echo -e "│                                                                                                    │"
	echo -e "│                                                                                                    │"
	echo -e "│                                                                                                    │"
	echo -e "│                                                                                                    │"
	echo -e "│                                                                                                    │"
	echo -e "│                                                                                                    │"
	echo -e "└────────────────────────────────────────────────────────────────────────────────────────────────────┘"
}

# Memulai game dengan menyeting kesulitan dan generasi jawaban random
# Menerima satu argument untuk menyatakan kesulitan dari game
start_game() {
	local choosen_diff=$1

	timer=${DIFFICULTY_TIMER[$choosen_diff]}
	penalty=${DIFFICULTY_PENALTY[$choosen_diff]}

	populate_answers

	echo "${answers[@]}"

	# Render ulang ui untuk menghapus ui sebelumnya
	render_base_ui

	# Entry ke game_loop
	game_loop
}

# Looping sesi game. Keluar dari fungsi ini hanya terjadi jika menang / waktu habis
game_loop() {
	# Penghitungan timer bomb dengan menghitung berapa kali render telah terjadi
	# Diatur dengan konfigurasi frame per seconds dan time per frame (timeout looping)
	local frame_count=1
	iterate_timer() {
		if (( frame_count == FRAME_PER_SECOND )); then
			timer=$((timer-1))
			frame_count=0
		else 
			frame_count=$((frame_count+1))
		fi
	}

	# Render base game ui
	local base_line=13
	local base_col=21
	echo -e "\e[${base_line};${base_col}H██────────────────────╤══╤─────╤══╤─────────────────────██"
	((base_line++))
	echo -e "\e[${base_line};${base_col}H██                    │  │     │  │                     ██   ┌──────────┐        "
	((base_line++))
	echo -e "\e[${base_line};${base_col}H██                  ╔═╧══╧══╤══╧══╧═╗                   ██═══│ 0 ANGKA  │════════"
	((base_line++))
	echo -e "\e[${base_line};${base_col}H██                  ║ TIMER │       ║                   ██   │   BENAR  │        "
	((base_line++))
	echo -e "\e[${base_line};${base_col}H██══════════════════╠═══╤═══╪═══╤═══╣═══════════════════██═══├──────────┤════════"
	((base_line++))
	echo -e "\e[${base_line};${base_col}H██                  ║ / │ / │ / │ / ║                   ██   │ 0 SALAH  │        "
	((base_line++))
	echo -e "\e[${base_line};${base_col}H██                  ╚═╤═╧╤══╧══╤╧═╤═╝                   ██═══│   TEMPAT │════════"
	((base_line++))
	echo -e "\e[${base_line};${base_col}H██                    │  │     │  │                     ██   └──────────┘        "
	((base_line++))
	echo -e "\e[${base_line};${base_col}H██────────────────────╧══╧─────╧══╧─────────────────────██"

	echo -e "\e[23;87HESC: MENYERAH"

	# Variables
	local guess=()

	# fungsi rendering timer
	render_timer() {
		local timer_line=16
		local timer_col=52

		echo -e "\e[${timer_line};${timer_col}H\e[1;31m${timer}  "
	}

	# fungsi rendering tebakan
	render_guess() {
		# render kosongan
		local guess_line=18
		local guess_col_arr=(43 47 51 55)
		if ((${#guess[@]} == 0)) ; then
			for (( i=0; i<4; i++)); do
				printf "\e[%d;%dH/" "$guess_line" "${guess_col_arr[$i]}"
			done
		fi
		# Render aktual
		for (( i=0; i<${#guess[@]}; i++)); do
			printf "\e[%d;%dH%d" "$guess_line" "${guess_col_arr[$i]}" "${guess[$i]}"
		done
	}

	# fungsi render clue
	render_clue() {
		local correct_count=$1
		local misplaced_count=$2

		local clue_line=15
		local clue_col=84
		echo -e "\e[$clue_line;${clue_col}H$correct_count"
		clue_line=18
		echo -e "\e[$clue_line;${clue_col}H$misplaced_count"
	}

	# fungsi render KEMENANGAN
	render_win() {
		local loop_count=0

		# render tanda DEFUSED
		local defused_line=16
		local defused_col=50
		echo -e "\e[${defused_line};${defused_col}H\e[1;32mDEFUSED"

		while (( loop_count < 10)); do
			local color_mode="\e[1;32m"
			if (( loop_count % 2 == 0)); then
				color_mode="\e[0;32m"
			fi
			echo -e "$color_mode"
			render_guess
			echo -e "\e[0m"

			loop_count=$((loop_count+1))
			sleep 0.5
		done
	}

	# fungsi render KEKALAHAN
	render_lose_sequence() {
		# Render 4 sequence
		sequence=("\e[2;39m" "\e[0;39m" "\e[0;37m" "\e[1;37m")
		for (( seq=0; seq<${#sequence[@]}; seq++ )); do
			echo -ne "\e[H"
			echo -ne "${sequence[$seq]}"

			# Render blank di semua box
			for (( line=9; line<=25; line++)); do
				for(( col=0; col<=102; col++)); do
					echo -e "\e[${line};${col}H█"
				done
			done

			sleep 0.5
		done

		sleep 1
		echo -e "\e[1;47m\e[17;44HBOM MELEDAK\e[0m"

		sleep 2
	}


	local sleep_frame_count=0 # Sleep setelah jumlah guess 4, agar angka terakhir dirender sebelum lakukan pengecekan
	while (( 1 )); do
		# Catch timer habis
		if [[ $timer -eq '0' ]]; then
			render_lose_sequence
			break
		fi

		# Efficient rendering
		if [[ $frame_count -eq '1' ]]; then
			render_timer
		fi
		if (( frame_count % 5 == 0)); then
			render_guess
		fi

		read -r -s -n4 -t $SECOND_PER_FRAME key # Baca 4 karakter tapi dengan timeout
		if [[ $key == $'\e' ]]; then
			timer=0
		elif [[ $key =~ [0-9] ]]; then
			while (( 1 )); do
				for (( i=0; i<${#guess[@]}; i++ )); do
					if (( key == guess[i] )); then
						break 2
					fi
				done
				if ((${#guess[@]} < 4)); then
					guess+=("$key")
				fi
				break
			done
		fi

		if [[ ${#guess[@]} -eq "4" ]]; then
			sleep_frame_count=$((sleep_frame_count+1))

			if (( sleep_frame_count == 15)); then
				sleep_frame_count=0
				output=$(parse_guess "${guess[0]}" "${guess[1]}" "${guess[2]}" "${guess[3]}")
				output_array=()
				for v in $output; do
					output_array+=("$v")
				done

				if [[ ${output_array[0]} -eq '4' ]]; then
					render_win
					break
				fi

				# Kurangi timer dengan penalti kesulitan
				timer=$((timer - penalty))
				# Rerender untuk refresh langsung
				render_timer

				render_clue "${output_array[0]}" "${output_array[1]}"
				
				guess=()
				render_guess
			fi
		fi

		iterate_timer
	done

	
}

# Entry point dari game, mengontrol pemilihan menu awal
main_menu() {
	# Tampilkan base ui
	render_base_ui

	# fungsi untuk render menu
	render_main_menu() {
		# Tampilkan ui main menu
		local mm_line=9
		local mm_col=10
		echo -e "\e[${mm_line};${mm_col}HA SIMPLE CODE GUESSING GAME"
		mm_line=$((mm_line+2))
		echo -e "\e[${mm_line};${mm_col}HCARA BERMAIN:"
		((mm_line++))
		echo -e "\e[${mm_line};${mm_col}H- TEBAK 5 ANGKA YANG TERSUSUN SECARA ACAK"
		((mm_line++))
		echo -e "\e[${mm_line};${mm_col}H- SETIAP MENEBAK KAMU AKAN DIBERIKAN CLUE:"
		((mm_line++))
		echo -e "\e[${mm_line};${mm_col}H	- BERAPA ANGKA YANG BENAR"
		((mm_line++))
		echo -e "\e[${mm_line};${mm_col}H	- BERAPA ANGKA YANG ADA TAPI SALAH POSISI"
		((mm_line++))
		echo -e "\e[${mm_line};${mm_col}H- SETIAP ANGKA HANYA MUNCUL SEKALI"
		((mm_line++))
		echo -e "\e[${mm_line};${mm_col}H- TEBAK SEBELUM WAKTU HABIS!"
		((mm_line++))
		((mm_line++))
		echo -e "\e[${mm_line};${mm_col}H- TERDAPAT PENALTI SETIAP MENEBAK TERGANTUNG KESULITAN"
		((mm_line++))
		echo -e "\e[${mm_line};${mm_col}H- WAKTU TIMER BOMB BERBEDA TERGANTUNG KESULITAN"
		((mm_line++))
		mm_line=23
		mm_col=75
		echo -e "\e[${mm_line};${mm_col}H<- / -> UNTUK PILIH MENU"  
	}

	# langsung render main menu di awal
	render_main_menu

	local selector=0 # 0-3 Kesulitan, 4 Exit
	# Looping render selector & pemilihan menu
	while (( 1 )); do
		## Render menu pilihan
		local mm_line=23
		local mm_col=6
		for (( i=0; i<5; i++ )); do
			local text=""
			case "$i" in
				'0') text="Easy";;
				'1') text="Medium";;
				'2') text="Hard";;
				'3') text="Extreme";;
				'4') text="Exit";;
				*);;
			esac

			# Setup warna tombol
			local color_mode="\e[0m"
			if [[ $i -eq $selector ]]; then
				color_mode="\e[1;47m"
			fi

			# Setup line & kolom awal
			if [[ $i -eq "0" ]]; then
				echo -ne "\e[${mm_line};${mm_col}H"
			fi

			# Render
			echo -ne "${color_mode}${text}\e[0m    "
		done


		## Terima satu input
		read -rsn1 key
		
		# Handle enter key 
		if [[ -z "$key" ]]; then
			case "$selector" in
				'0'|'1'|'2'|'3')
					# Jika selector berada di 0-3 maka mulai game berdasarkan selector (kesulitan game)
					start_game $selector
					
					# Render ulang ui setelah sesi game selesai
					render_base_ui
					render_main_menu
					continue
				;;
				'4')
				exit 0 
				;;
			esac
		fi


		if [[ $key == $'\e' ]]; then
			# Ambil 2 karakter selanjutnya
			read -rsn2 key
		fi

		# Deteksi value key input
		case "$key" in
			'[C')
				# Panah kanan (\e[C)
				if (( selector < 4 )); then
					selector=$((selector+1))
				fi
				;;
			'[D')
				# Panah kiri (\e[D)
				if (( selector > 0 )); then
					selector=$((selector-1))
				fi
				;;
		esac
	done
}

# Menghilangkan kursor saat game berjalan
setterm -cursor off

# Fungsi cleanup: membersihkan terminal dan mengembalikan cursor
cleanup() {
	setterm -cursor on
	echo -ne "\e[3J"
	echo -ne "\e[2J"
	echo -ne "\e[H"
	echo -ne "\e[0m"
	exit 0
}

# Trap signal exit (dipanggil dari game) dan SIGINT (ctrl+C)
trap cleanup SIGINT
trap cleanup EXIT

# entry point main menu
main_menu

