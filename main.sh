#!/usr/bin/env bash

export NEWT_COLORS='
root=gray,gray
shadow=gray,gray
window=,gray
border=white,gray
textbox=white,red
button=black,white
'

whiptail --title "Menu example" --menu "Choose an option" 25 78 16 \
" <-- Return" "" \
"Continent" "Choose a continent" \
"Country" "Choose a country" \
"Gheu" "Choose ta bonne grosse mère" \
"Add Group" "Add a user group to the system." \
"Modify Group" "Modify a group and its list of members." \
"List Groups" "List all groups on the system."

