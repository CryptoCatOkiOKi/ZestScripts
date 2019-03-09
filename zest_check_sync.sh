#!/bin/bash

PARAM1=$*
NAME="zest"
BLOCKHASHCOINEXPLORER=$(curl -s4 https://www.coinexplorer.net/api/${NAME}/block/latest | jq -r ".result.hash")
LATESTWALLETVERSION="1000301"

if [ -z "$PARAM1" ]; then
  PARAM1="*"  	  
else
  PARAM1=${PARAM1,,} 
fi

sudo apt-get install -y jq > /dev/null 2>&1

for FILE in ~/bin/${NAME}d_$PARAM1.sh; do
  sleep 2
  echo "****************************************************************************"
  echo FILE: " $FILE"

  STARTPOS=$(echo $FILE | grep -b -o _)
  LENGTH=$(echo $FILE | grep -b -o .sh)
  STARTPOS_1=$(echo ${STARTPOS:0:2})
  STARTPOS_1=$[STARTPOS_1 + 1]
  ALIAS=$(echo ${FILE:STARTPOS_1:${LENGTH:0:2}-STARTPOS_1})  
  
  PID=`ps -ef | grep -i $ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
  echo "PID="$PID

  if [ -z "$PID" ]; then
    echo "${NAME} $ALIAS is STOPPED can't check if synced!"
  else
  
	  LASTBLOCK=$(~/bin/${NAME}-cli_$ALIAS.sh getblockcount)
	  GETBLOCKHASH=$(~/bin/${NAME}-cli_$ALIAS.sh getblockhash $LASTBLOCK)  
	    
	  WALLETVERSION=$(~/bin/${NAME}-cli_$ALIAS.sh getinfo | grep -i \"version\")
	  WALLETVERSION=$(echo $WALLETVERSION | tr , " ")
	  WALLETVERSION=$(echo $WALLETVERSION | tr '"' " ")
	  WALLETVERSION=$(echo $WALLETVERSION | tr 'version : ' " ")
	  WALLETVERSION=$(echo $WALLETVERSION | tr -d ' ' )
	  
	  if ! [ "$WALLETVERSION" == "$LATESTWALLETVERSION" ]; then
	     echo "!!!Your wallet $ALIAS is OUTDATED!!!"
	  fi

	  echo "LASTBLOCK="$LASTBLOCK
	  echo "GETBLOCKHASH="$GETBLOCKHASH
	  echo "BLOCKHASHCOINEXPLORER="$BLOCKHASHCOINEXPLORER
	  echo "WALLETVERSION="$WALLETVERSION
	  
	  if [ "$GETBLOCKHASH" == "$BLOCKHASHCOINEXPLORER" ]; then
		echo "Wallet $FILE is SYNCED!"
	  else
		if [ "$BLOCKHASHCOINEXPLORER" == "Too" ]; then
		   echo "COINEXPLORER Too many requests"
		else 
		   echo "Wallet $FILE is NOT SYNCED!"
		fi
	  fi
  fi
done