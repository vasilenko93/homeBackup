#! /bin/bash

# Created by Alex Vasilenko


timeStamp=$(date +%Y%m%d_%H%M)
version=v1.7

#Font Colors
black=$(tput setaf 0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
colreset=$(tput sgr0)
txtbld=$(tput bold)

#Background colors
bblack=$(tput setab 0)

#Creates backup folder if not exists
#if statment not working, it always trys to create a folder
if [ -d "~/.homeBack_Ups" ]; then
 	chmod 700 ~/.homeBack_Ups
else
	mkdir ~/.homeBack_Ups
	chmod 700 ~/.homeBack_Ups
fi

function createNewBackup()
{
 timeStamp=$(date +%Y%m%d_%H%M)
 #Checks if backup exists for this timeStamp
 if [ -f ~/.homeBack_Ups/$timeStamp.tar.gz ]; then
	 echo "${green}"
	 echo "================================================================="
	 echo -e "${red}Error: ${green}Backup exists for this timestamp."
	 read -p $timeStamp
	 return 1
 fi

 #moves to user's home folder and creates the backup
 cd ~
 #I give credit for this bit of the code to galaktos from Reddit
 #http://www.reddit.com/r/bash/comments/36378b/new_user_tar_ignore_folders/crabt79
 excludes=(.homeBack_Ups .cache .dropbox Dropox .steam .mozilla Downloads BTSync)
 excludesOptions() {
    for exclude in "${excludes[@]}"; do
        echo "--exclude=$exclude"
    done
 }
 #end of credit
 tar -cvzf ~/.homeBack_Ups/$timeStamp.tar.gz $(excludesOptions) . > ~/.homeBack_Ups/$timeStamp.files

 #makes the backup only accessible by owner, and not writable
 chmod 500 ~/.homeBack_Ups/$timeStamp.tar.gz

 echo ""
 echo "================================================================="
 echo -e "${green}${USER} a backup of your home folder was created."
 echo -e "${blue}${timeStamp}${green}.tar.gz"
 read -p "Press [Enter] to return back to main menu."

}

function restoreEntireBackup()
{
 cd ~/.homeBack_Ups
 fileArray=(*.tar.gz)
 numberOfBackups=${#fileArray[@]}

 clear
 echo -e "${green}
|===============================================================|
|======================${red} Restore a backup${green} =======================|
|===============================================================|
"
 if [ ${fileArray[0]} == "*.tar.gz" ]; then
 	numberOfBackups=0
 fi
 if [ $numberOfBackups -ge 1 ]; then
 	i=0
 	#one=1
	backUpPicked=0
	if [ $numberOfBackups -eq 1 ]; then
    	echo -e "${cyan}$numberOfBackups ${green}backup found in: ${blue}$(pwd)"
	else
    	echo -e "${cyan}$numberOfBackups ${green}backups found in: ${blue}$(pwd)"
	fi
    echo "${green}------------------------------------------"
    echo -e "| ${red}#${green} | Year Month Day Hour Minute (24 hour)"
    echo "|---|-------------------------------------"

    for (( i; i < $numberOfBackups; i++ ))
    do
        num=$(($i + 1))
        echo -e "| ${red}${num} ${green}| ${fileArray[i]}"
    done
	echo ""
	echo "Choose a backup to restore"
    echo -ne "or anything else to cancel ${red}#${green} "
    goodInput=0
	read input

	if [ $input -ge "1" -a $input -le $numberOfBackups ]; then
		goodInput=1
	fi

	if [ $goodInput -eq "1" ]; then
		clear
		cd ~/.homeBack_Ups
		backUpPicked=$(($input - 1))
		echo "Restoring backup ${fileArray[backUpPicked]}..."
		tar -xzvfk ${fileArray[backUpPicked]} -C ~
		read -p "Restore complete."
	else
		read -p "Restore canceled."
	fi
 else
 	echo -e "No backups found in: ${blue}$(pwd)${green}"
 	read -p "Press [Enter] to return to menu."
 fi
}

function restoreFile()
{
    cd ~/.homeBack_Ups
    backupArray=(*.tar.gz)
    filesArray=(*.files)
    numberOfBackups=${#backupArray[@]}

    clear
    echo -e "${green}
|===============================================================|
|======================= ${red}Restore a file ${green}========================|
|===============================================================|
"
    if [ ${backupArray[0]} == "*.tar.gz" ]; then
        numberOfBackups=0
    fi
    if [ $numberOfBackups -ge 1 ]; then
        filename=""
        while [ ${#filename} -lt 1 ]
        do
            echo -n "${green}Type the file you want to restore ${red}> "
            read filename
        done

        filesfound=()
        index=0
        selection=1
        for backup in "${backupArray[@]}"
        do
            echo -e "${red}${backup} |========================>${green}"
            filesfound_temp=( $(cat ${backup%%.*}.files | grep -i ${filename}) )
            # Problem, does not remove duplicates
            filesfound=("${filesfound[@]}" "${filesfound_temp[@]}")
            positions[index]=0
            for file in "${filesfound_temp[@]}"
            do
                echo -e "| ${red}${selection} ${green}|  ${file}"
                positions[index]=$selection
                ((selection++))
            done
            ((index++))
        done

        echo ""
        echo "Choose a file to restore"
	    echo -ne "or 'q' to cancel ${red}# ${green}"
        goodInput=0
        read input

        if [[ "${input[0]}" == "q" || "${input[0]}" == "Q" ]]; then
            goodInput=0
        elif [ $input -ge 1 -a $input -le $selection ]; then
            goodInput=1
        fi

        if [ $goodInput -eq 1 ]; then
            restore_index=0
            while [ ${positions[restore_index]} -lt $input  ]
            do
                ((restore_index++))
            done
            filesindex=$((input-1))
            tar -xf ${backupArray[restore_index]} -C ~ ${filesfound[filesindex]}
            echo -e "${green}File ${blue}${filesfound[filesindex]} ${green}restored."
            read -p "${green}Press [Enter] to return back to main menu."
        else
            read -p "${green}Press [Enter] to return back to main menu."
        fi
    else
        echo -e "${green}No backups found in: ${blue}$(pwd)"
        read -p "Press [Enter] to return to menu."
    fi
}

function deleteBackup()
{
    cd ~/.homeBack_Ups
    backupArray=(*.tar.gz)
    filesArray=(*.files)
    numberOfBackups=${#backupArray[@]}

    clear
    echo -e "${green}
|===============================================================|
|======================= ${red}Delete a backup ${green}=======================|
|===============================================================|
"
    if [ ${backupArray[0]} == "*.tar.gz" ]; then
        numberOfBackups=0
    fi
    if [ $numberOfBackups -ge 1 ]; then
        i=0
        #one=1
        backUpPicked=0
		if [ $numberOfBackups -eq 1 ]; then
			 echo -e "${cyan}$numberOfBackups ${green}backup found in: ${blue}$(pwd)"
		else
			echo -e "${cyan}$numberOfBackups ${green}backups found in: ${blue}$(pwd)"
        fi
        echo "${green}------------------------------------------"
        echo -e "| ${red}# ${green}| Year Month Day Hour Minute (24 hour)"
        echo "|---|-------------------------------------"

        for (( i; i < $numberOfBackups; i++ ))
        do
            num=$(($i + 1))
            echo -e "| ${red}${num} ${green}|  ${backupArray[i]}"
        done
        echo ""
        echo "Choose a backup to delete"
	    echo -ne "or 'q' to cancel ${red}# ${green}"
        goodInput=0
        read input

        if [[ "${input[0]}" == "q" || "${input[0]}" == "Q" ]]; then
            goodInput=0
        elif [ $input -ge "1" -a $input -le $numberOfBackups ]; then
            goodInput=1
        fi

        if [ $goodInput -eq 1 ]; then
            clear
            cd ~/.homeBack_Ups
            backUpPicked=$(($input - 1))
            echo -en "${green}Deleting ${red}${backupArray[backUpPicked]} ${green}..."
		    chmod 600 ${backupArray[backUpPicked]}
            rm ${backupArray[backUpPicked]}
            rm ${filesArray[backUpPicked]}
            echo -e "${red} Deleted."
            read -p "${green}Press [Enter] to return back to main menu."
        else
            read -p "${green}Press [Enter] to return back to main menu."
        fi
    else
        echo -e "${green}No backups found in: ${blue}$(pwd)"
        read -p "Press [Enter] to return to menu."
    fi
}

# where the script starts

choice=0
while [ "$choice" != "5" ]
do
 clear
 echo -e "${green}${txtbld}
 |===============================================================|
 |====================|     ${red}vasalex.com    ${green}|=====================|
 |====================| ${red}Home backup script ${green}|=====================|
 |====================|        ${red}Enjoy       ${green}|=====================|
 |===============================================================|
 ${colreset}"
 cd ~
 echo -e "${green}Version:\t\t ${blue}${version}"
 echo -e "${green}Active user:\t\t ${blue}${USER}"
 echo -e "${green}User home directory:\t ${blue}$(pwd)"
 echo ""
 echo -e "${green}1) Backup home directory."
 echo -e "${green}2) Restore an Entire backup."
 echo -e "${green}3) Restore a file"
 echo -e "${green}4) Delete a backup."
 echo -e "${green}5) Exit"
 echo -ne "${green}>>> "
 read choice

 case "$choice" in
  1)
	createNewBackup
  ;;
  2)
	restoreEntireBackup
  ;;
  3)
    restoreFile
  ;;
  4)
    deleteBackup
  ;;
  5)
	clear
  ;;
  *)
	echo -e "${red}Error: Invalid input."
	read -p "${green}Press [Enter] to try again."
  ;;
 esac

done
