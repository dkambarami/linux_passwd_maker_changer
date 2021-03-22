#!/bin/sh
########################################################################################################
##            This script automates the CREATION of passwords for LINUX servers                       ##
##                                 Created on 20201007                                                ##
########################################################################################################


cd `dirname $0`
hour=`date +'%Y%m%d%H%M'`
outputfile=log/password_maker_$hour.log
passwordfile=passwords_list
inputfile=../.passwords_list.conf
perl_inst=/usr/bin/perl
chars_in_password=10   #password lenght - NOT USED IN SCRIPT
declare -A serverTypesPassword

if [ ! -f $inputfile ]; then echo file $inputfile not found; exit; fi

echo "${hour} ************************************* Program Password Maker Started *********************************************" >> $outputfile

##################################                  Declare Group of Servers                #################################################

serverTypesArr=("OCS" "OLC" "UIP" "NMS" "CDR" "PCRF" "PCEF" "PHUB" "DB" "APP" "OTHER")

##################################            Make the password for each group of servers   #################################################

for type in ${serverTypesArr[@]};do
	typePassword=`$perl_inst -le 'print map {(a..z,A..Z,0..9,qw{/ $ ] & ?})[rand 67] }0..10'`
	serverTypesPassword[$type]=$typePassword	
done

mv $passwordfile bak/${passwordfile}_${hour}

##################################            Define Password File Header   #################################################
echo '##List of servers to check
## Server Types - "OCS" "OLC" "UIP" "NMS" "CDR" "PCRF" "PCEF" "PHUB" "DB" "APP"   -- To add more edit the script
## ANY refers to any type - you can use it when you do not want to put servers into types. Works like N/A.
##format : serverShortName|serverIP|serverType|serverUser|newPassword' > $passwordfile

cat $inputfile | grep -v "##" | grep -v ^$ | while read mydata   ##DO NOT USE DOUBLE # IN PASSWORDS 0 RESERVED FOR COMMENTING
do
	serverName=`echo $mydata | cut -d "|" -f1`
	serverIP=`echo $mydata | cut -d "|" -f2`
	serverType=`echo $mydata | cut -d "|" -f3`
	serverUser=`echo $mydata | cut -d "|" -f4`
	if [ -z "${serverTypesPassword["$serverType"]+x}" ];then
	  echo "##### Passwords Creations failed for : "$serverName  >> $passwordfile
	elif [[ '$serverType' = 'ANY' ]];then
	    serverPassword=`perl -le 'print map {(a..z,A..Z,0..9,qw{/ $ ] & ?})[rand 67] }0..10'`
		echo $serverName"|"$serverIP"|'$serverType'|"$serverUser"|$serverPassword}|" >> $passwordfile
	else
	   echo $serverName"|"$serverIP"|"$serverType"|"$serverUser"|${serverTypesPassword["$serverType"]}|" >> $passwordfile
   fi
done
   mv  $passwordfile ..
echo "${hour} ************************************* Program Password Maker Completed *********************************************" >> $outputfile


