#! /bin/bash ###############################################
#Created by Alex Vasilenko #################################
############################################################
#Protected from being copyrighted because it is copylefted #
############################################################

timeStamp=$(date +%Y%m%d_%H%M)
userName=$(whoami)
VERSION=v1.01

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
	 echo ""
	 echo "================================================================="
	 echo -e "\e[31mError:\e[0m Backup exists for this timestamp."
	 read -p $timeStamp
	 return 1
 fi

 #moves to user's home folder and creates the backup
 cd ~
 tar -cvzf ~/.homeBack_Ups/$timeStamp.tar.gz --exclude='.homeBack_Ups' .

 #makes the backup only accessible by owner, and not writable
 chmod 500 ~/.homeBack_Ups/$timeStamp.tar.gz

 echo ""
 echo "================================================================="
 echo -e "\e[34m$userName\e[0m a backup of your home folder was created."
 echo -e "\e[31m$timeStamp\e[0m.tar.gz"
 read -p "Press [Enter]"

}

function restoreBackup()
{
 cd ~/.homeBack_Ups
 fileArray=(*.tar.gz)
 numberOfBackups=${#fileArray[@]}
 
 clear
 echo -e "\e[32m
|===============================================================|
|======================\e[31m Restore a backup\e[32m =======================|
|===============================================================|
\e[0m"
 if [ ${fileArray[0]} == "*.tar.gz" ]; then
	numberOfBackups=0
 fi
 if [ $numberOfBackups -ge 1 ]; then
 	i=0
 	#one=1
	backUpPicked=0
	if [ $numberOfBackups -eq 1 ]; then
    	echo -e "\e[96m$numberOfBackups\e[0m backup found in: \e[34m$(pwd)\e[0m"
	else
    	echo -e "\e[96m$numberOfBackups\e[0m backups found in: \e[34m$(pwd)\e[0m"
	fi
 	echo "------------------------------------------"
  	echo -e "| \e[31m#\e[0m | Year Month Day Hour Minute (24 hour)"
  	echo "|---|-------------------------------------"

  	for (( i; i < $numberOfBackups; i++ ))
  	do
  		num=$(($i + 1))
		echo -e "|\e[91m $num\e[0m | ${fileArray[i]}"
  	done
	echo ""
	echo "Choose a backup to restore"
  	echo -ne "or anything else to cancel. \e[91m#\e[0m"
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
		tar -xzvf ${fileArray[backUpPicked]} -C ~
		read -p "Restore complete."
	else
		read -p "Restore canceled."
	fi
 else
 	echo -e "No backups found in: \e[34m$(pwd)\e[0m"
 	read -p "Press [Enter] to return to menu."
 fi
}

function deleteBackup()
{
 cd ~/.homeBack_Ups
 fileArray=(*.tar.gz)
 numberOfBackups=${#fileArray[@]}
 clear
 echo -e "\e[32m
|===============================================================|
|======================= \e[31mDelete a backup\e[32m =======================|
|===============================================================|
\e[0m "
if [ ${fileArray[0]} == "*.tar.gz" ]; then
        numberOfBackups=0
 fi
 if [ $numberOfBackups -ge 1 ]; then
        i=0
        #one=1
        backUpPicked=0
		if [ $numberOfBackups -eq 1 ]; then
			 echo -e "\e[96m$numberOfBackups\e[0m backup found in: \e[34m$(pwd)\e[0m"
		else
			echo -e "\e[96m$numberOfBackups\e[0m backups found in: \e[34m$(pwd)\e[0m"
        fi
		echo "------------------------------------------"
        echo -e "| \e[31m#\e[0m | Year Month Day Hour Minute (24 hour)"
        echo "|---|-------------------------------------"

        for (( i; i < $numberOfBackups; i++ ))
        do
                num=$(($i + 1))
                echo -e "| \e[91m$num\e[0m |  ${fileArray[i]}"
        done
        echo ""
		echo "Choose a backup to delete"
		echo -ne "or anything else to cancel. \e[91m#\e[0m"
        goodInput=0
        read input

        if [ $input -ge "1" -a $input -le $numberOfBackups ]; then
                goodInput=1
        fi

        if [ $goodInput -eq "1" ]; then
                clear
                cd ~/.homeBack_Ups
                backUpPicked=$(($input - 1))
                echo -e "Deleting \e[31m${fileArray[backUpPicked]}\e[0m..."
		chmod 600 ${fileArray[backUpPicked]}
                rm ${fileArray[backUpPicked]}
                read -p "Deleted."
        else
                read -p "Did not delete anything."
        fi
 else
        echo -e "No backups found in: \e[34m$(pwd)\e[0m"
        read -p "Press [Enter] to return to menu."
 fi
}

choice=0
while [ "$choice" != "4" ]
do
 clear
 echo -e "\e[32m
 |===============================================================|
 |====================|     \e[31mvasalex.com    \e[32m|=====================|
 |====================| \e[31mHome backup script \e[32m|=====================|
 |====================|        \e[31mEnjoy       \e[32m|=====================|
 |===============================================================|
 \e[0m"
 cd ~
 echo -e "Version:\t\t \e[34m$VERSION\e[0m"
 echo -e "Active user:\t\t \e[34m$userName\e[0m"
 echo -e "User home directory:\t \e[34m$(pwd)\e[0m"
 echo ""
 echo -e "\e[31m1)\e[0m Backup home directory."
 echo -e "\e[31m2)\e[0m Restore a backup."
 echo -e "\e[31m3)\e[0m Delete a backup."
 echo -e "\e[31m4)\e[0m Exit"
 echo -ne "\e[32m>>>\e[0m "
 read choice

 case "$choice" in
  1)
	createNewBackup
  ;;
  2)
	restoreBackup
  ;;
  3)
  	deleteBackup
  ;;
  4)
	clear
  ;;
  *)
	echo -e "\e[31mError: \e[0mInvalid input."
	read -p "Press [Enter]"
  ;;
 esac

done




