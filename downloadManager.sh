#!/bin/bash
INPUT=/tmp/menu.sh.$$
OUTPUT=/tmp/output.sh.$$
DIALOG=${DIALOG=dialog}
# trap and delete temp files
trap "rm $OUTPUT; rm $INPUT; exit" SIGHUP SIGINT SIGTERM

function display_downloaded(){
    local h=${1-10}			# box height default 10
    local w=${2-10} 		# box width default 41
    local t=${3-Output} 	# box title
    dialog --backtitle "DOWNLOAD HISTORY" --title "${t}" --clear --msgbox "$(cat Downloaded.txt)" ${h} ${w}
}
#
# Purpose - display downloaded file
#
function show_downloaded(){
    echo "Today is $(date) @ $(hostname -f)." >$OUTPUT
    display_downloaded 30 80 "Download History"
}
#
# Purpose - display a donwload manager
#
function show_downloadManager(){
    FILE=`$DIALOG --backtitle "DOWNLOAD MANAGER"  --stdout --title "Please choose a file" --fselect $HOME/Desktop/ 20 80`
    case $? in
        0)
            grep -oE '(http|https):\/\/[^ ]*' $FILE > LastDownloaded.txt #| grep -oE '(http|https):\/\/[^ ]*' $FILE >> Downloaded.txt
            while read p; do
                wget "$p" 2>&1 | \
                stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | dialog --gauge "$p" 10 100
                echo "$p" >> Downloaded.txt
            done <LastDownloaded.txt
            clear
            dialog --infobox "All files are downloaded" 5 28
        sleep 2 ;;
        1)
        dialog --infobox "Error" 5 25 ;;
        255)
        echo "Box closed.";;
    esac
}
#
# set infinite loop
#
while true
do
    ### display main menu ###
    dialog --clear  --backtitle "CE350 ---- Download Manager Application ---- Onat Çakır | Yiğitcan Yılmaz  " \
    --title "  [ M A I N - M E N U ]" \
    --menu "\n    You can use the UP/DOWN arrow keys or \n\
    number keys 1-9 to choose an option." 15 50 4 \
    1 "New Download" \
    2 "Download History" \
    3 "Exit" 2>"${INPUT}"
    
    menuitem=$(<"${INPUT}")
    
    # make decsion
    case $menuitem in
        1) show_downloadManager;;
        2) show_downloaded;;
        3) echo "Bye"; break;;
    esac
    
done

# if temp files found, delete em
[ -f $OUTPUT ] && rm $OUTPUT
[ -f $INPUT ] && rm $INPUT