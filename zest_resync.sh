#!/bin/bash

NAME="zest"
BLOCKHASHCOINEXPLORER=$(curl -s4 https://www.coinexplorer.net/api/${NAME}/block/latest | jq -r ".result.hash")	

##
## Script sync wallet using current bootstrap
##

PARAM1=$*
PARAM1=${PARAM1,,} 

sudo apt-get install -y jq > /dev/null 2>&1

if [ -z "$PARAM1" ]; then
  echo "Need to specify node alias!"
  exit -1
fi

if [ ! -f ~/bin/${NAME}d_$PARAM1.sh ]; then
    echo "Wallet $PARAM1 not found!"
	exit -1
fi

for FILE in ~/bin/${NAME}d_$PARAM1.sh; do
  echo "****************************************************************************"
  COUNTER=1
  DATE=$(date '+%d.%m.%Y %H:%M:%S');
  echo "DATE="$DATE
  echo FILE: " $FILE"
  STARTPOS=$(echo $FILE | grep -b -o _)
  LENGTH=$(echo $FILE | grep -b -o .sh)./mon
  # echo ${STARTPOS:0:2}
  STARTPOS_1=$(echo ${STARTPOS:0:2})
  STARTPOS_1=$[STARTPOS_1 + 1]
  ALIAS=$(echo ${FILE:STARTPOS_1:${LENGTH:0:2}-STARTPOS_1})
  CONFPATH=$(echo "$HOME/.${NAME}_$ALIAS")
  # echo $STARTPOS_1
  # echo ${LENGTH:0:2}
  echo CONF DIR: $CONFPATH
  
  if [ ! -d $CONFPATH ]; then
	echo "Directory $CONFPATH not found!"
	exit -1
  fi	   
  
  for (( ; ; ))
  do
    sleep 2
	
	PID=`ps -ef | grep -i $ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
	echo "PID="$PID
	
	if [ -z "$PID" ]; then
	  echo "${NAME} $ALIAS is STOPPED can't check if synced!"
	fi
  
	LASTBLOCK=$(~/bin/${NAME}-cli_$ALIAS.sh getblockcount)
	GETBLOCKHASH=$(~/bin/${NAME}-cli_$ALIAS.sh getblockhash $LASTBLOCK)

	echo "LASTBLOCK="$LASTBLOCK
	echo "GETBLOCKHASH="$GETBLOCKHASH

	echo "LASTBLOCK="$LASTBLOCK
	echo "GETBLOCKHASH="$GETBLOCKHASH
	echo "BLOCKHASHCOINEXPLORER="$BLOCKHASHCOINEXPLORER


	echo "GETBLOCKHASH="$GETBLOCKHASH
	echo "BLOCKHASHCOINEXPLORER="$BLOCKHASHCOINEXPLORER

	if [ "$BLOCKHASHCOINEXPLORER" == "Too" ]; then
	   echo "COINEXPLORER Too many requests"
	   break  
	fi
	
	# Wallet is not synced
	echo $DATE" Wallet $ALIAS is NOT SYNCED!"
	#
	# echo $LASTBLOCKCOINEXPLORER
	#break
	
	if [ -z "$PID" ]; then
	   echo ""
	else
		#STOP 
		~/bin/${NAME}-cli_$ALIAS.sh stop

		if [[ "$COUNTER" -gt 1 ]]; then
		  kill -9 $PID
		fi
	fi
	
	sleep 3 # wait 3 seconds 
	PID=`ps -ef | grep -i $ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
	echo "PID="$PID
	
	if [ -z "$PID" ]; then
	  echo "Monk $ALIAS is STOPPED"
	  
	  cd $CONFPATH
	  echo CURRENT CONF FOLDER: $PWD
	  echo "Copy BLOCKCHAIN without conf files"
	  wget http://194.135.84.214/${NAME}/bootstrap/bootstrap.zip -O bootstrap.zip
	  # rm -R peers.dat 
	  rm -R ./database
	  rm -R ./blocks	
	  rm -R ./sporks
	  rm -R ./chainstate		  
	  unzip  bootstrap.zip
	  $FILE
	  sleep 5 # wait 5 seconds 
	  
	  PID=`ps -ef | grep -i $ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
	  echo "PID="$PID
	  
	  if [ -z "$PID" ]; then
		echo "${NAME} $ALIAS still not running!"
	  fi
	  
	  break
	else
	  echo "${NAME} $ALIAS still running!"
	fi
	
	COUNTER=$[COUNTER + 1]
	echo COUNTER: $COUNTER
	if [[ "$COUNTER" -gt 9 ]]; then
	  break
	fi		
  done		
done
