#!/bin/sh
########################################################################################################
##            This script automates the USER passwords for LINUX servers                              ##
##                                Created on 20201007                                                 ##
########################################################################################################

cd `dirname $0`
hour=`date +'%Y%m%d%H%M'`
outputfile=log/password_feedback_$hour.log
recipientIP=10.118.118.118  #Collection Point for passwords
perl_inst=/usr/bin/perl
PATH=/miniconda3/condabin:/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/home/BASIC_CHECK/scripts/checks/


if [ ! -f $inputfile ]; then echo file $inputfile not found; exit; fi
	###### Call the Password Maker Program #######
echo "${hour} ************************************* Program Make Password Started*********************************************" >> $outputfile
sh pmaker/make_passwd.sh #>> $outputfile
echo "${hour} ************************************* Program Make Password Completed*********************************************" >> $outputfile


	###### Call the Password Change Program #######
echo "${hour} ************************************* Program Password Change Started*********************************************" >> $outputfile
inputfile=passwords_list  #File created by password maker
cat $inputfile | grep -v "##" | grep -v ^$ | while read mydata   ##DO NOT USE DOUBLE # IN PASSWORDS 0 RESERVED FOR COMMENTING
do
	serverName=`echo $mydata | cut -d "|" -f1`
	serverIP=`echo $mydata | cut -d "|" -f2`
	serverType=`echo $mydata | cut -d "|" -f3`
	serverUser=`echo $mydata | cut -d "|" -f4`
	newPassword=`echo $mydata | cut -d "|" -f5`
	
	###### Change the password for serverUser using password from a file list #######
	
	ssh -n  $serverIP usermod -p `${perl_inst} -e 'print crypt($ARGV[0], "seeding"),"\n";' -- $newPassword` $serverUser &>> $outputfile 
	retval=$?
	if [ $retval -ne 0 ];then
		echo "$serverIP - $serverName  password change FAILED ********"  >> $outputfile 
		echo $retval >> $outputfile 
	fi
done
echo "${hour} ************************************* Sending File to RecipientIP Server *********************************************" >> $outputfile
   scp $inputfile $recipientIP:/root/Documents/secure/.${inputfile}_${hour}.csv
   mv  $inputfile bak/${inputfile}_${hour}.used
   tail -f $outputfile
echo "${hour} ************************************* Program Password Change Completed *********************************************" >> $outputfile


