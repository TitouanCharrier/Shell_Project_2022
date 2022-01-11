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

i=1
while [ -n "${Continent_Consumption[0,$i]}" ] ; do
	echo ${Continent_Consumption[0,$i]}
	((i++))
done

main_menu



