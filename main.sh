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

	CHOICE=$(whiptail --title "Main menu" --menu --notags "What do you want ?" 10 35 2 \
	"1" "Generate a file tree"  \
	"2" "Get a specific information"  \
	3>&1 1>&2 2>&3)

	if [ $? -eq 1 ] ; then
		exit
	fi

	case $CHOICE in
		"1" ) gene ;;
		"2" ) info ;;
	esac
}

gene() {

	CHOICE=$(whiptail --title "Generate a file tree" --inputbox  "Generate about :" 8 40 \
	3>&1 1>&2 2>&3)

	choice=${CHOICE,,}

	if [ $? -eq 1 ] ; then
		main_menu
	fi

	i=1
	while [ -n "${Country_Consumption[0,$i]}" ] ; do
		if [ "${Country_Consumption[0,$i]}" == $choice ] ; then
			index=$i
			print_country_col $index
		fi
		((i++))
	done

	i=1
	while [ -n "${Continent_Consumption[0,$i]}" ] ; do
		if [ "${Continent_Consumption[0,$i]}" == $choice ] ; then
			index=$i
			print_continent_col $index
		fi
		((i++))
	done
}

print_country_col() {
	i=1
	while [ -n "${Country_Consumption[$i,$index]}" ] ; do
		echo ${Country_Consumption[$i,$index]}
		((i++))
	done
}

print_continent_col() {
	i=1
	while [ -n "${Continent_Consumption[$i,$index]}" ] ; do
		echo ${Continent_Consumption[$i,$index]}
		((i++))
	done
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
