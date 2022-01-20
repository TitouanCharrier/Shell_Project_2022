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

#this function execute the menu who able you to choose what you want
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
		"3" ) info_menu ;;
	esac
}

#this function execute the menu who able you to choose a way to search
method_menu() {
	CHOICE_method=$(whiptail --title "Method selection" --menu --notags "Search by : " --cancel-button "Back" 10 35 4 \
	"1" "Search by name"  \
	"2" "Browse list"  \
	3>&1 1>&2 2>&3)

	if [ $? -eq 1 ] ; then
		main_menu
	fi

	if [ $CHOICE -eq 1 ] ; then

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

#this function execute the menu who able you to input your need (graph)
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

#this function execute the menu who able you to input your need (csv)
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

#this function find the chosen country / continent in the docs
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

#this function execute the menu who able you to choose a country / continent
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

#this function execute the menu who able you to return to the main menu or exit
end() {
	if (whiptail --title "Done" --yesno "Need anything more ?" --yes-button "Main menu" --no-button "Exit" 8 78) ; then
		main_menu
	else
		exit
	fi
}

#this function create the tree and set the image inside
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

#this function execute the menu who able you to choose a specific information
info_menu() {
	CHOICE=$(whiptail --title "Specific informations" --menu --notags "Want to know about : " --cancel-button "Back" 11 60 4 \
	"1" "The country who produce the more \"green\" electricity"  \
	"2" "The country who produce the less \"green\" electricity"  \
	"3" "The production of renewable energy"  \
	"4" "The comparison of renewable / fossil energy"  \
	3>&1 1>&2 2>&3)

	if [ $? -eq 1 ] ; then
		main_menu
	fi

	case $CHOICE in
		"1" ) green_max ;;
		"2" ) green_min ;;
		"3" ) renewable_power_gen_per_year ;;
		"4" ) global_generation ;;
	esac 
}

#this function execute the menu who able you know what pays produce the more green power
green_max() {

	i=1
	max_value=0
	max_index=1
	while [ -n "${Country_Renewable[$i,5]}" ] ; do
	
		if [ $(bc <<< "${Country_Renewable[$i,5]} > $max_value") -eq 1 ] ; then
			max_value=${Country_Renewable[$i,5]}
			max_index=$i
		fi
		((i++))
	done

	whiptail --msgbox --title "Result" "${Country_Renewable[$max_index,0]} is the country who produce the greatest amount of \"green\" electricity \n his production is ${Country_Renewable[$max_index,5]} TWH" 10 40
	end
}

#this function execute the menu who able you know what pays produce the less green power
green_min() {

	i=1
	min_value=${Country_Renewable[1,5]}
	min_index=1
	while [ -n "${Country_Renewable[$i,5]}" ] ; do

		if [ $(bc <<< "${Country_Renewable[$i,5]} < $min_value") -eq 1 ] ; then
			min_value=${Country_Renewable[$i,5]}
			min_index=$i
		fi
		((i++))
	done

	whiptail --msgbox --title "Result" "${Country_Renewable[$min_index,0]} is the country who produce the smallest amount of \"green\" electricity \n his production is ${Country_Renewable[$min_index,5]} TWH" 10 40
	end
}

#this function make the tree and set the csv inside
conso(){
	i=1
	if [ "$mode" == "country" ] ; then

		mkdir -p results/"$choice" 
		echo -e "Year,$choice\n" >> results/"$choice"/"$choice.csv"

		while [ -n "${Country_Consumption[$i,$index]}" ] ; do
			echo -e "${Country_Consumption[$i,0]},${Country_Consumption[$i,$index]}\n" >> results/"$choice"/"$choice.csv"
			((i++))
		done

	else

		mkdir -p results/"$choice" 
		echo -e "Year,$choice\n" >> results/"$choice"/"$choice.csv"

		while [ -n "${Continent_Consumption[$i,$index]}" ] ; do
			echo -e "${Continent_Consumption[$i,0]},${Continent_Consumption[$i,$index]}\n" >> results/"$choice"/"$choice.csv"
			((i++))
		done
	fi
	end
}

#this function execute the menu who able you to know the generation per year
renewable_power_gen_per_year(){

	year=$(whiptail --title "Renewable generation per year" --menu "Choose a year" 30 35 20 \
	"1990" "" \
	"1991" "" \
	"1992" "" \
	"1993" "" \
	"1994" "" \
	"1995" "" \
	"1996" "" \
	"1997" "" \
	"1998" "" \
	"1999" "" \
	"2000" "" \
	"2001" "" \
	"2002" "" \
	"2003" "" \
	"2004" "" \
	"2005" "" \
	"2006" "" \
	"2007" "" \
	"2008" "" \
	"2009" "" \
	"2010" "" \
	"2011" "" \
	"2012" "" \
	"2013" "" \
	"2014" "" \
	"2015" "" \
	"2016" "" \
	"2017" "" \
	3>&1 1>&2 2>&3)

	if [ $? -eq 1 ] ; then
		main_menu
	
	else
		tr -d '\r' <./src_files/renewablePowerGeneration97-17.csv>./src_files/renewablePowerGeneration97-17.csv.temp
		name2=$(head -n 1 src_files/renewablePowerGeneration97-17.csv.temp | cut -d ',' -f2)
		name3=$(head -n 1 src_files/renewablePowerGeneration97-17.csv.temp | cut -d ',' -f3)
		name4=$(head -n 1 src_files/renewablePowerGeneration97-17.csv.temp | cut -d ',' -f4)
		name5=$(head -n 1 src_files/renewablePowerGeneration97-17.csv.temp | cut -d ',' -f5)
		value2=$(grep $year src_files/renewablePowerGeneration97-17.csv.temp | cut -d ',' -f2)
		value3=$(grep $year src_files/renewablePowerGeneration97-17.csv.temp | cut -d ',' -f3)
		value4=$(grep $year src_files/renewablePowerGeneration97-17.csv.temp | cut -d ',' -f4)
		value5=$(grep $year src_files/renewablePowerGeneration97-17.csv.temp | cut -d ',' -f5)
		whiptail --msgbox --title "Results" " $name2 : $value2 \n $name3 : $value3 \n $name4 : $value4 \n $name5 : $value5 \n" 10 60
		rm ./src_files/renewablePowerGeneration97-17.csv.temp
	fi
	end
}

#this function execute the menu who able you to know the global generation
global_generation() {
	whiptail --msgbox --title "Results" " comparison of production \n between renewable and fossil energy \n \n \
	${Global_Renewable[1,0]} >> ${Global_Renewable[1,1]} | ${Global_Fossil[1,1]} << ${Global_Fossil[1,0]} \n
	${Global_Renewable[2,0]} >> ${Global_Renewable[2,1]} | ${Global_Fossil[2,1]} << ${Global_Fossil[2,0]} \n
	${Global_Renewable[3,0]} >> ${Global_Renewable[3,1]} | ${Global_Fossil[3,1]} << ${Global_Fossil[3,0]} \n
	${Global_Renewable[4,0]} >> ${Global_Renewable[4,1]} | ${Global_Fossil[4,1]} << ${Global_Fossil[4,0]} \n
	${Global_Renewable[5,0]} >> ${Global_Renewable[5,1]} | ${Global_Fossil[5,1]} << ${Global_Fossil[5,0]} \n
	${Global_Renewable[6,0]} >> ${Global_Renewable[6,1]} | ${Global_Fossil[6,1]} << ${Global_Fossil[6,0]} \n
	${Global_Renewable[7,0]} >> ${Global_Renewable[7,1]} | ${Global_Fossil[7,1]} << ${Global_Fossil[7,0]} \n
	${Global_Renewable[8,0]} >> ${Global_Renewable[8,1]} | ${Global_Fossil[8,1]} << ${Global_Fossil[8,0]} \n
	${Global_Renewable[9,0]} >> ${Global_Renewable[9,1]} | ${Global_Fossil[9,1]} << ${Global_Fossil[9,0]} \n
	" 30 70
}


# --- parsing docs in matrix --- #

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

tr -d '\r' <./src_files/top20CountriesPowerGeneration.csv>./src_files/top20CountriesPowerGeneration.csv.temp

i=0
declare -A Country_Renewable
while IFS=, read -r -a line; do
   for ((j = 0; j < ${#line[@]}; ++j)); do
        Country_Renewable[$i,$j]=${line[$j],,}
    done
    ((i++))
done < ./src_files/top20CountriesPowerGeneration.csv.temp

rm ./src_files/top20CountriesPowerGeneration.csv.temp

tr -d '\r' <./src_files/renewablesTotalPowerGeneration.csv>./src_files/renewablesTotalPowerGeneration.csv.temp

i=0
declare -A Global_Renewable
while IFS=, read -r -a line; do
   for ((j = 0; j < ${#line[@]}; ++j)); do
        Global_Renewable[$i,$j]=${line[$j],,}
    done
    ((i++))
done < ./src_files/renewablesTotalPowerGeneration.csv.temp

rm ./src_files/renewablesTotalPowerGeneration.csv.temp

tr -d '\r' <./src_files/nonRenewablesTotalPowerGeneration.csv>./src_files/nonRenewablesTotalPowerGeneration.csv.temp

i=0
declare -A Global_Fossil
while IFS=, read -r -a line; do
   for ((j = 0; j < ${#line[@]}; ++j)); do
        Global_Fossil[$i,$j]=${line[$j],,}
    done
    ((i++))
done < ./src_files/nonRenewablesTotalPowerGeneration.csv.temp

rm ./src_files/nonRenewablesTotalPowerGeneration.csv.temp

# --- beginning --- #

main_menu
