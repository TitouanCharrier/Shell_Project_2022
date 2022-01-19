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

	CHOICE=$(whiptail --title "Main menu" --menu --notags "What do you want ?" --cancel-button "Exit" 10 35 4 \
	"1" "Generate a graph"  \
	"2" "Generate a csv file"  \
	"3" "Get a specific information"  \
	3>&1 1>&2 2>&3)

	if [ $? -eq 1 ] ; then
		exit
	fi

	case $CHOICE in
		"1" ) method_menu $CHOICE;;
		"2" ) method_menu $CHOICE;;
		"3" ) info ;;
	esac
}

method_menu() {
	CHOICE_method=$(whiptail --title "Method selection" --menu --notags "Search by : " --cancel-button "Exit" 10 35 4 \
	"1" "Name"  \
	"2" "Browsing"  \
	3>&1 1>&2 2>&3)

	if [ $? -eq 1 ] ; then
		exit
	fi

	if [ $CHOICE -eq 0 ] ; then

		browser_var=0

		case $CHOICE_method in
			"1" ) ask ;;
			"2" ) browser $browser_var ;;
		esac
	else 

		browser_var=1
		case $CHOICE_method in
			"1" ) ask_conso ;;
			"2" ) browser $browser_var;;
		esac
	fi
}

ask() {

	CHOICE=$(whiptail --title "Generate a graph" --inputbox  "Generate about :" --cancel-button "Back" 8 40 \
	3>&1 1>&2 2>&3)

	choice=${CHOICE,,}

	if [ $? -eq 0 ] ; then
		conso_var=0
		test_entry $choice $conso_var 
	else
		main_menu 
	fi
}

ask_conso() {

	CHOICE=$(whiptail --title "Generate csv file" --inputbox  "Generate about :" --cancel-button "Back" 8 40 \
	3>&1 1>&2 2>&3)

	choice=${CHOICE,,}

	if [ $? -eq 0 ] ; then
		conso_var=1
		test_entry $choice $conso_var 
	else
		main_menu 
	fi
}

test_entry() {

	success=0
	i=1
	while [ -n "${Country_Consumption[0,$i]}" ] ; do
		
		if [ "${Country_Consumption[0,$i]}" == "$choice" ] ; then
			index=$i
			mode="country"
			((success++))
			if [ $conso_var -eq 0 ] ; then
				print_graph $index $mode
			else
				conso $choice $mode
			fi
		fi
		((i++))
	done

	i=1
	while [ -n "${Continent_Consumption[0,$i]}" ] ; do
		if [ "${Continent_Consumption[0,$i]}" == "$choice" ] ; then
			index=$i
			mode="continent"
			((success++))
			if [ $conso_var -eq 0 ] ; then
				print_graph $index $mode
			else
				conso $choice $mode
			fi
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
	"North America" "" \
	"Latin America" "" \
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

	if [ $browser_var -eq 0 ] ; then
		conso_var=0
	else
		conso_var=1
	fi

	test_entry $choice $conso_var
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

	echo -e "set terminal png size 1920,1080 \n set output '$choice.png' \n set title 'Consumption of "$CHOICE" by years (TWH)' \n plot \"data_set.dat\" w lp " >> temp.p

	mkdir -p results/"$choice" 

	gnuplot temp.p

	mv "$choice.png" results/"$choice"

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

info() {
	CHOICE=$(whiptail --title "Specific informations" --menu --notags "Want to know about : " --cancel-button "Back" 10 60 3 \
	"1" "The country who produce the more \"green\" electricity"  \
	"2" "The country who produce the less \"green\" electricity"  \
	3>&1 1>&2 2>&3)

	if [ $? -eq 1 ] ; then
		main_menu
	fi

	case $CHOICE in
		"1" ) green_max ;;
		"2" ) green_min ;;
		"3" ) info ;;
	esac
}

green_max() {

	i=1
	max_value=0
	max_index=1
	while [ -n "${Country_Renewable[$i,5]}" ] ; do
		
		echo "${Country_Renewable[$i,5]}"
		echo $max_value

		if [ $(bc <<< "${Country_Renewable[$i,5]} < $max_value") -eq 1 ] ; then
			echo high
			max_value=${Country_Renewable[$i,5]}
			max_index=$i
		fi
		((i++))
	done

	whiptail --msgbox --title "Result" "${Country_Renewable[$max_index,0]} is the country who produce the greatest amount of \"green\" electricity \n his production is ${Country_Renewable[$max_index,5]} TWH" 10 40
}

green_min() {

	i=1
	min_value=0
	min_index=1
	while [ -n "${Country_Renewable[$i,5]}" ] ; do

		if [ "${Country_Renewable[$i,5]}" < $min_value ] ; then
			min_value=${Country_Renewable[$i,5]}
			min_index=$i
		fi
		((i++))
	done

	whiptail --msgbox --title "Result" "${Country_Renewable[$min_index,0]} is the country who produce the greatest amount of \"green\" electricity \n his production is ${Country_Renewable[$min_index,5]} TWH" 10 40
}

_conso_(){
	head -n 1 src_files/Country_Consumption_TWH.csv | awk -F',' ' { for (i=1+1; i<= NF; i++) print $i} ' 
	echo "Pick a country from the list above"
	read choice
	mkdir -p results/$choice
	col=`awk -F',' ' { for (i=1; i<= NF; i++) print i, $i; exit} ' src_files/Country_Consumption_TWH.csv | grep $choice | awk '{print $1}'`
	cat src_files/Country_Consumption_TWH.csv | cut -d ',' -f1 $col > results/$choice/conso.csv
	sed -i -e "s/,/ /g" results/$choice/conso.csv
	cat results/$choice/conso.csv
	}

	conso(){
	i=1
	if [ "$mode" == "country" ] ; then

		echo -e "Year,$choice\n" >> results/"$choice"/"$choice.csv"

		while [ -n "${Country_Consumption[$i,$index]}" ] ; do
			echo -e "${Country_Consumption[$i,0]},${Country_Consumption[$i,$index]}\n" >> results/"$choice"/"$choice.csv"
			((i++))
		done

	else

		while [ -n "${Continent_Consumption[$i,$index]}" ] ; do
			echo -e "${Continent_Consumption[$i,0]},${Continent_Consumption[$i,$index]}\n" >> results/"$choice"/"$choice.csv"
			((i++))
		done
	fi
	end
	}


ReneblePowerGenPerYear(){
	echo "enter a year between 1990 and 2017 to his renewable power generation"
	read year
	if [ 1990 -lt $year -a $year -lt 2017 ]
	then
		head -n 1 src_files/renewablePowerGeneration97-17.csv | cut -d ',' -f2,3,4,5
		grep $year src_files/renewablePowerGeneration97-17.csv | cut -d ',' -f2,3,4,5 #/{for (i=2; i<=NF; i++) print $i}
	else
		echo "enter a year between 1990 and 2017"   
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

i=0
declare -A Country_Consumption
while IFS=, read -r -a line; do
   for ((j = 0; j < ${#line[@]}; ++j)); do
        Country_Consumption[$i,$j]=${line[$j],,}
    done
    ((i++))
done < ./src_files/Country_Consumption_TWH.csv

i=0
declare -A Country_Renewable
while IFS=, read -r -a line; do
   for ((j = 0; j < ${#line[@]}; ++j)); do
        Country_Renewable[$i,$j]=${line[$j],,}
    done
    ((i++))
done < ./src_files/top20CountriesPowerGeneration.csv

main_menu
