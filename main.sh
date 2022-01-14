#!/usr/bin/env bash

# --- colors --- #

#export NEWT_COLORS='
#root=gray,gray
#shadow=gray,gray
#window=,gray
#border=white,gray
#textbox=white,red
#button=black,white
#'

# --- functions --- #

main_menu() {

	CHOICE=$(whiptail --title "Main menu" --menu --notags "What do you want ?" --cancel-button "Exit" 10 35 3 \
	"1" "Generate a file tree"  \
	"2" "Browse country / continents"  \
	"3" "Get a specific information"  \
	3>&1 1>&2 2>&3)

	if [ $? -eq 1 ] ; then
		exit
	fi

	case $CHOICE in
		"1" ) ask ;;
		"2" ) browser ;;
		"3" ) info ;;
	esac
}

ask() {

	CHOICE=$(whiptail --title "Generate a file tree" --inputbox  "Generate about :" 8 40 \
	3>&1 1>&2 2>&3)

	choice=${CHOICE,,}

	if [ $? -eq 1 ] ; then
		main_menu
	fi

	test_entry $choice


}

test_entry() {

	success=0
	i=1
	while [ -n "${Country_Consumption[0,$i]}" ] ; do
		if [ "${Country_Consumption[0,$i]}" == $choice ] ; then
			index=$i
			mode="country"
			((success++))
			print_graph $index $mode
		fi
		((i++))
	done

	i=1
	while [ -n "${Continent_Consumption[0,$i]}" ] ; do
		if [ "${Continent_Consumption[0,$i]}" == $choice ] ; then
			index=$i
			mode="continent"
			((success++))
			print_graph $index $mode
		fi
		((i++))
	done

	if [ $success -eq 0 ] ; then
		whiptail --msgbox --title "Error" "continent or country not referenced \n please try a different syntax" 10 40
		main_menu
	fi
}

browser() {

	CHOICE=$(whiptail --title "Main menu" --menu "What do you want ?" 30 35 20 \
	"World" "" \
	"OECD" "" \
	"BRICS" "" \
	"Europe" "" \
	"North" "" \
	"America" "" \
	"Latin" "" \
	"America" "" \
	"Asia" "" \
	"Pacific" "" \
	"Africa"	"" \
	"Middle-East" "" \
	"CIS" "" \
	"China" ""	\
	"United States" "" \
	"Brazil" "" \
	"Belgium" "" \
	"Czechia" "" \
	"France" "" \
	"Germany" "" \
	"Italy" "" \
	"Netherlands" "" \
	"Poland" "" \
	"Portugal" "" \
	"Romania" "" \
	"Spain" "" \
	"Sweden" "" \
	"United Kingdom" "" \
	"Norway" "" \
	"Turkey" "" \
	"Kazakhstan" "" \
	"Russia" "" \
	"Ukraine" "" \
	"Uzbekistan" "" \
	"Argentina" "" \
	"Canada" "" \
	"Chile" "" \
	"Colombia" "" \
	"Mexico" "" \
	"Venezuela" "" \
	"Indonesia" "" \
	"Japan" "" \
	"Malaysia" "" \
	"South Korea" "" \
	"Taiwan" "" \
	"Thailand" "" \
	"India" "" \
	"Australia" "" \
	"New Zealand" "" \
	"Algeria" "" \
	"Egypt" "" \
	"Nigeria" "" \
	"South Africa" "" \
	"Iran" "" \
	"Kuwait" "" \
	"Saudi Arabia" "" \
	"United Arab Emirates" "" \
	3>&1 1>&2 2>&3)

	if [ $? -eq 1 ] ; then
		main_menu
	fi

	choice=${CHOICE,,}

	test_entry $choice
}

end() {
	if (whiptail --title "Done" --yesno "Need anything more ?" --yes-button "Main menu" --no-button "Exit" 8 78) ; then
		main_menu
	else
		exit
	fi
}

print_graph() {
	i=1
	cat /dev/null > data_set.dat
	cat /dev/null > temp.p

	if [ "$mode" == "country" ] ; then

		while [ -n "${Country_Consumption[$i,$index]}" ] ; do
			echo -e "${Country_Consumption[$i,0]} \t ${Country_Consumption[$i,$index]}" >> data_set.dat
			((i++))
		done

	else

		while [ -n "${Continent_Consumption[$i,$index]}" ] ; do
			echo -e "${Continent_Consumption[$i,0]} \t ${Continent_Consumption[$i,$index]}" >> data_set.dat
			((i++))
		done

	fi

	echo -e "set terminal png size 1920,1080 \n set output '$choice.png' \n set title 'Consumption of $CHOICE by years (TWH)' \n plot \"data_set.dat\" w lp " >> temp.p

	mkdir -p results/$choice 

	gnuplot temp.p

	mv $choice.png results/$choice

	rm temp.p data_set.dat

	end
}

print_continent_col() {
	i=1
	while [ -n "${Continent_Consumption[$i,$index]}" ] ; do
		echo ${Continent_Consumption[$i,$index]}
		((i++))
	done
}

add_to_file() {
	echo -e "${Continent_Consumption[$i,0]} \t ${Continent_Consumption[$i,$index]}"
}

# --- beginning --- #

i=0
declare -A Continent_Consumption
while IFS=, read -r -a line; do
   for ((j = 0; j < ${#line[@]}; ++j)); do
        Continent_Consumption[$i,$j]=${line[$j],,}
    done
    ((i++))
done < ./src_files/Continent_Consumption_TWH.csv

i=0
declare -A Country_Consumption
while IFS=, read -r -a line; do
   for ((j = 0; j < ${#line[@]}; ++j)); do
        Country_Consumption[$i,$j]=${line[$j],,}
    done
    ((i++))
done < ./src_files/Country_Consumption_TWH.csv

i=1
while [ -n "${Continent_Consumption[0,$i]}" ] ; do
	#echo ${Continent_Consumption[0,$i]}
	((i++))
done

main_menu
