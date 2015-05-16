#! /bin/bash

# Created by Alex Vasilenko


timeStamp=$(date +%Y%m%d_%H%M)
userName=$(whoami)
version=v1.5

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
 excludes=(.homeBack_Ups .cache .steam Downloads)
 excludesOptions() {
    for exclude in "${excludes[@]}"; do
        echo "--exclude=$exclude"
    done
 }
 tar -cvzf ~/.homeBack_Ups/$timeStamp.tar.gz $(excludesOptions) .
 #end of credit

 #makes the backup only accessible by owner, and not writable
 chmod 500 ~/.homeBack_Ups/$timeStamp.tar.gz

 echo ""
 echo "================================================================="
 echo -e "${green}${userName} a backup of your home folder was created."
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
    echo -e "${red}TODO"
    read -p "${green}Press [Enter] to return to menu."

}

function deleteBackup()
{
    cd ~/.homeBack_Ups
    fileArray=(*.tar.gz)
    numberOfBackups=${#fileArray[@]}
    clear
    echo -e "${green}
|===============================================================|
|======================= ${red}Delete a backup ${green}=======================|
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
			 echo -e "${cyan}$numberOfBackups ${gree}backup found in: ${blue}$(pwd)"
		else
			echo -e "${cyan}$numberOfBackups ${gree}backups found in: ${blue}$(pwd)"
        fi
        echo "${gree}------------------------------------------"
        echo -e "| ${red}# ${green}| Year Month Day Hour Minute (24 hour)"
        echo "|---|-------------------------------------"

        for (( i; i < $numberOfBackups; i++ ))
        do
            num=$(($i + 1))
            echo -e "| ${red}${num} ${green}|  ${fileArray[i]}"
        done
        echo ""
        echo "Choose a backup to delete"
	    echo -ne "or anything else to cancel ${red}# ${green}"
        goodInput=0
        read input

        if [ $input -ge "1" -a $input -le $numberOfBackups ]; then
            goodInput=1
        fi

        if [ $goodInput -eq "1" ]; then
            clear
            cd ~/.homeBack_Ups
            backUpPicked=$(($input - 1))
            echo -en "${green}Deleting ${red}${fileArray[backUpPicked]} ${green}..."
		    chmod 600 ${fileArray[backUpPicked]}
            rm ${fileArray[backUpPicked]}
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
 echo -e "${green}Active user:\t\t ${blue}${userName}"
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
	echo -p "${red}Error: Invalid input."
	read -p "${green}Press [Enter] to try again."
  ;;
 esac

done
